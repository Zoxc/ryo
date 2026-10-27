/-
Ryo.Proofs.DecodeLink.Items — what the candidate parsers return (aot.md §C2, toward M3
`decode_sound`), for the links that need more of `decodeItem`'s output than that it is in
memory: the `xmm` fields of `Call.XmmOk`, and the frame form without a frame pointer.

- `baseCandidate_ok`, `sseCandidate_ok`, `nativeCandidate_noXmm`: `Cursor::base_item`'s items
  have no memory operand and a `movd` register below 8 (`BaseOk`); an SSE item has the size of
  `movss`, `movsd` or `movups`, a register below 8 (3-bit ModRM fields) and base `rbp` or `rsp`;
  a native item is no `xmm` item (`NoXmm`).
- `decodeItem_xmmOk`: every item `decodeItem` returns is `XmmOk`, in either frame form
  (`fromSpFrame` keeps an SSE item's base `rbp`: with a frame pointer it rejects `rsp`, without
  one it maps `[rsp + _]` to `[rbp + _]`). `Dec.xmmOk`: so is every item of a `Dec` run.
- `link_call_ok`: `link_call` without the `XmmOk` hypothesis: `Call.callSeq` / `Call.tailSeq` of
  the operands are the items in memory.

**Without a frame pointer** (`c.spFrame = some F`): `decodeItem` returns the encoder's
`[rbp + d]` form `j` of the item `i` it matched, `[rsp + F + d]`, and `j.spFrame F = i`
(`fromSpFrame_sp`; a base item has no memory operand). So the item in memory is
`j.spFrame F` (`decodeItem_itemAt_sp`), and a run `Dec c p items q` is
`CodeAt` of `items.map (·.spFrame F)` (`codeAt_of_dec_sp`, `LinkOkSp.dec`, the analogue of
`LinkOk.dec`): each per-shape link of `Links`/`Call`/`Inline` holds in this form with `hk.dec`
replaced by `LinkOkSp.dec`, the items mapped. The step lemmas don't take that form: `RRel`
fixes `rbp = fp`, and `Shapes`, `CacheStep`, `CacheMem`, `Call`, `ArgRet` (but for its
`add rsp, F + 8` epilogue) run the `[rbp + d]` items. A step lemma for the mapped items (`rsp + F
= fp` in place of `rbp = fp`) is what the mode still needs; it isn't a decoder link.
-/
import Ryo.Proofs.DecodeLink.Call

set_option linter.constructorNameAsVariable false
set_option linter.unusedSimpArgs false

namespace Ryo.Proofs.DecodeLink

open Ryo.X86 Ryo.Vm Ryo.Vm.R Ryo.Vm.Asm

theorem u8_and7 (m : UInt8) : (m &&& 7).toNat < 8 := by
  rw [UInt8.toNat_and]; exact Nat.lt_of_le_of_lt Nat.and_le_right (by decide)

/-! ### The candidates -/

/-- What `Cursor::base_item` returns: no memory operand, a `movd` register below 8. -/
def BaseOk (i : Item) : Prop := i.mem? = none ∧ XmmOk i

theorem winPiece_ok {c : Cursor} {i : Item} (h : c.winPiece = some i) : BaseOk i := by
  unfold Cursor.winPiece at h
  repeat' (first | (simp only [Option.some.injEq, reduceCtorEq] at h) | (split at h))
  all_goals (subst h; exact ⟨rfl, trivial⟩)

theorem baseNoRex_ok {c : Cursor} {op : UInt8} {i : Item}
    (h : Cursor.baseCandidate.baseNoRex c op = some i) : BaseOk i := by
  unfold Cursor.baseCandidate.baseNoRex at h
  simp only [bind, pure] at h
  repeat' (first
    | (simp only [Option.bind_eq_some_iff, Option.bind_none, Option.bind_some, Option.some.injEq,
        reduceCtorEq, Functor.map, Option.map_eq_some_iff, exists_const] at h)
    | (split at h) | (obtain ⟨_, _, h⟩ := h))
  all_goals first | exact ⟨rfl, trivial⟩ | exact ⟨rfl, u8_and7 _⟩

set_option maxHeartbeats 10000000 in
/-- `baseCandidate`'s items (a case split over its parse, ~30 s). -/
theorem baseCandidate_ok {c : Cursor} {i : Item} (h : c.baseCandidate = some i) : BaseOk i := by
  unfold Cursor.baseCandidate at h
  simp only [bind, pure] at h
  repeat' (first
    | (simp only [Option.bind_eq_some_iff, Option.bind_none, Option.bind_some, Option.some.injEq,
        reduceCtorEq, Functor.map, Option.map_eq_some_iff, exists_const] at h)
    | (split at h) | (obtain ⟨_, _, h⟩ := h))
  all_goals first | exact ⟨rfl, trivial⟩ | exact winPiece_ok ‹_› | exact baseNoRex_ok ‹_›

/-- `sseCandidate`'s items: `movss`/`movsd`/`movups` of a register below 8, off `rbp` or `rsp`. -/
theorem sseCandidate_ok {c : Cursor} {i : Item} (h : c.sseCandidate = some i) :
    ∃ s z x m, i = .sse s z x m ∧ (z = 4 ∨ z = 8 ∨ z = 16) ∧ x < 8 ∧
      (m.base = .rbp ∨ m.base = .rsp) := by
  unfold Cursor.sseCandidate at h
  simp only [bind, Option.bind_eq_some_iff, pure] at h
  obtain ⟨b0, -, h⟩ := h
  have key : ∀ pre size, (size = 4 ∨ size = 8 ∨ size = 16) → (do
    if ((← c.get pre) != 0x0f) = true then none
    let op2 ← c.get (pre + 1)
    if (!(op2 == 0x10 || op2 == 0x11)) = true then none
    let at_ := pre + 2
    let m ← c.get at_
    let (md, x, rm) := (m >>> 6, (m >>> 3 &&& 7).toNat, m &&& 7)
    let (base, d) ← if rm == 5 then some (Reg.rbp, at_ + 1)
      else if rm == 4 && (← c.get (at_ + 1)) == 0x24 then some (Reg.rsp, at_ + 2)
      else none
    let disp ← if md == 0 && base == .rsp then some 0
      else if md == 1 then sext8 <$> c.get d
      else if md == 2 then c.i32At d
      else none
    pure (Item.sse (op2 == 0x11) size x ⟨base, disp⟩) : Option Item) = some i →
      ∃ s z x m, i = .sse s z x m ∧ (z = 4 ∨ z = 8 ∨ z = 16) ∧ x < 8 ∧
        (m.base = .rbp ∨ m.base = .rsp) := by
    clear h
    intro pre size hs h
    simp only [bind, pure] at h
    repeat' (first
      | (simp only [Option.bind_eq_some_iff, Option.bind_none, Option.bind_some, Option.some.injEq,
          reduceCtorEq, Functor.map, Option.map_eq_some_iff, exists_const] at h)
      | (split at h) | (obtain ⟨_, _, h⟩ := h))
    all_goals exact ⟨_, _, _, _, rfl, hs, u8_and7 _, by simp⟩
  split at h <;> exact key _ _ (by decide) h

/-- Not an `xmm` item. -/
def NoXmm : Item → Prop
  | .sse .. | .movd .. => False
  | _ => True

/-- Every result of `o` satisfies `P`. -/
def OptAll {α : Type} (P : α → Prop) (o : Option α) : Prop := ∀ a, o = some a → P a

theorem optAll_none {α : Type} {P : α → Prop} : OptAll P none := fun _ h => by cases h
theorem optAll_some {α : Type} {P : α → Prop} {a : α} (h : P a) : OptAll P (some a) :=
  fun _ e => by cases e; exact h
theorem optAll_bind {α β : Type} {P : β → Prop} {x : Option α} {f : α → Option β}
    (h : ∀ a, OptAll P (f a)) : OptAll P (x.bind f) := fun b e => by
  obtain ⟨a, -, e⟩ := Option.bind_eq_some_iff.mp e; exact h a b e
theorem optAll_bind_item {P : Item → Prop} {x : Option Item} {f : Item → Option Item}
    (hx : OptAll P x) (h : ∀ a, P a → OptAll P (f a)) : OptAll P (x.bind f) := fun b e => by
  obtain ⟨a, ha, e⟩ := Option.bind_eq_some_iff.mp e; exact h a (hx a ha) b e

/-- `nativeCandidate` returns no `xmm` item: none of its branches builds one. -/
theorem nativeCandidate_noXmm {c : Cursor} {i : Item} (h : c.nativeCandidate = some i) :
    NoXmm i := by
  suffices hs : OptAll NoXmm c.nativeCandidate from hs i h
  unfold Cursor.nativeCandidate
  -- The join points and local helpers become local definitions; `modrm` and the helpers
  -- are kept abstract (no item comes from them), so the branches don't duplicate them.
  extract_lets g mem reg rmReg immAt dq byteW post body
  have hpost : ∀ it, NoXmm it → OptAll NoXmm (post it) := by
    intro it hit
    unfold post
    split <;> (try split) <;> first | exact optAll_none | exact optAll_some hit
  have hbody : ∀ x, OptAll NoXmm (body x) := by
    intro x
    unfold body
    split
    apply optAll_bind; intro op
    dsimp -zeta -zetaDelta only
    extract_lets i1 modrm dqw
    clear_value g mem reg rmReg immAt dq byteW modrm
    split
    all_goals
      repeat' (first
        | exact optAll_none
        | exact optAll_some trivial
        | (apply optAll_bind_item _ hpost)
        | refine optAll_bind fun _ => ?_
        | split)
  clear_value body
  repeat' (first
    | exact optAll_none
    | exact hbody _
    | refine optAll_bind fun _ => ?_
    | split)

theorem xmmOk_of_noXmm {i : Item} (h : NoXmm i) : XmmOk i := by
  cases i <;> first | trivial | exact h.elim

theorem noXmm_mapMem {i : Item} (f : M → M) (h : NoXmm i) : NoXmm (i.mapMem f) := by
  cases i <;> first
    | exact h
    | exact h.elim
    | (rename_i rm; cases rm <;> exact h)
    | (rename_i rm _; cases rm <;> exact h)

/-- What `fromSpFrame` does: maps a `[rsp + _]` operand without a frame pointer, else keeps
the item (rejecting `[rsp + _]` with a frame pointer and `[rbp + _]` without). -/
theorem fromSpFrame_cases {c : Cursor} {i j : Item} (h : c.fromSpFrame i = some j) :
    (∃ f m, c.spFrame = some f ∧ i.mem? = some m ∧ m.base = .rsp ∧
      j = i.mapMem (fun m => M.frame (m.disp - f))) ∨
    (j = i ∧ ∀ m, i.mem? = some m → m.base ≠ .rsp ∧ (m.base = .rbp → c.spFrame = none)) := by
  unfold Cursor.fromSpFrame at h
  generalize hsf : c.spFrame = sf at h
  generalize hmb : i.mem?.map (·.base) = mb at h
  revert h
  cases mb with
  | none =>
    cases sf <;> intro h <;> cases h <;>
      exact .inr ⟨rfl, fun m hm => by rw [hm] at hmb; cases hmb⟩
  | some b =>
    cases sf <;> cases b <;> intro h <;> cases h
    all_goals first
      | exact .inr ⟨rfl, fun m hm => by
          rw [hm] at hmb; simp only [Option.map_some, Option.some.injEq] at hmb; simp [hmb]⟩
      | (obtain ⟨m, hm, hb⟩ := Option.map_eq_some_iff.mp hmb
         exact .inl ⟨_, m, rfl, hm, hb, rfl⟩)

theorem fromSpFrame_noXmm {c : Cursor} {i j : Item} (hi : NoXmm i) (h : c.fromSpFrame i = some j) :
    NoXmm j := by
  rcases fromSpFrame_cases h with ⟨f, m, -, -, -, rfl⟩ | ⟨rfl, -⟩
  · exact noXmm_mapMem _ hi
  · exact hi

theorem fromSpFrame_sse {c : Cursor} {s : Bool} {z x : Nat} {m : M} {j : Item}
    (hb : m.base = .rbp ∨ m.base = .rsp) (h : c.fromSpFrame (.sse s z x m) = some j) :
    ∃ m', j = .sse s z x m' ∧ m'.base = .rbp := by
  rcases fromSpFrame_cases h with ⟨f, m', -, -, -, rfl⟩ | ⟨rfl, hk⟩
  · exact ⟨_, rfl, rfl⟩
  · have := hk m rfl
    rcases hb with hb | hb
    · exact ⟨m, rfl, hb⟩
    · exact absurd hb this.1

/-- Every item `decodeItem` returns is `XmmOk` (`Call.XmmOk`), in either frame form. -/
theorem decodeItem_xmmOk {c : Cursor} {i : Item} {n : Nat} (h : decodeItem c = some (i, n)) :
    XmmOk i := by
  have hacc : ∀ (post : Item → Option Item) (k : Item), c.accept post k = some (i, n) →
      post k = some i := by
    intro post k ha
    unfold Cursor.accept at ha
    split at ha
    · rename_i hp; cases ha; exact hp
    · cases ha
  unfold decodeItem at h
  rcases Option.orElse_some' h with h | h
  · obtain ⟨k, hk, h⟩ := Option.bind_eq_some_iff.mp h
    cases hacc _ _ h
    exact (baseCandidate_ok hk).2
  rcases Option.orElse_some' h with h | h
  · obtain ⟨k, hk, h⟩ := Option.bind_eq_some_iff.mp h
    obtain ⟨s, z, x, m, rfl, hz, hx, hb⟩ := sseCandidate_ok hk
    obtain ⟨m', rfl, hm'⟩ := fromSpFrame_sse hb (hacc _ _ h)
    exact ⟨hz, hx, hm'⟩
  · obtain ⟨k, hk, h⟩ := Option.bind_eq_some_iff.mp h
    exact xmmOk_of_noXmm (fromSpFrame_noXmm (nativeCandidate_noXmm hk) (hacc _ _ h))

theorem Dec.xmmOk {c : Cursor} {p q : Nat} {items : List Item} (h : Dec c p items q) :
    ∀ it ∈ items, XmmOk it := by
  induction h with
  | nil => intro it hit; cases hit
  | cons hd _ ih =>
    intro it hit
    rcases List.mem_cons.mp hit with rfl | hit
    · exact decodeItem_xmmOk hd
    · exact ih it hit

/-- `link_call` with its `XmmOk` hypothesis discharged (`decodeItem_xmmOk`). -/
theorem link_call_ok {ctx : Ctx} {m : Mem} {c c' : Cursor} {rs : Array Reloc} {fr : Frame}
    {dropped : List DroppedStore} {q : Proto} (hk : LinkOk ctx m c rs) (hb : Boundary rs c.pos)
    (h : (callInsn fr dropped).run c = .ok (some q, c')) :
    (∃ (fo : Opnd Nat) (d : BitVec 32) (k : BitVec 64) (ws : List (BitVec 32)) (items : List Item),
      q.ops = [.slot d, fo, .imm k, .words ws] ∧ q.handler = none ∧
      Call.callSeq fr.mode.pe q.op fo ws = some items ∧
      CodeAt ctx m (items ++ resultStores k.toNat d) c.pos ∧
      c'.pos = c.pos + codeSize (items ++ resultStores k.toNat d) ∧ Boundary rs c'.pos) ∨
    (∃ (fo : Opnd Nat) (ws : List (BitVec 32)) (items : List Item),
      q.ops = [fo, .words ws] ∧ q.handler = none ∧
      Call.tailSeq fr.size fr.mode q.op fo ws = some items ∧
      CodeAt ctx m items c.pos ∧ c'.pos = c.pos + codeSize items ∧ Boundary rs c'.pos) := by
  cases callInsn_read h with
  | @call f fo pre ps ci ws d k site c'' hhead hd _ hps hk32 =>
    have hkk : (BitVec.ofNat 64 k).toNat = k := by
      rw [BitVec.toNat_ofNat]; exact Nat.mod_eq_of_lt (by omega)
    have hx := hd.xmmOk
    obtain ⟨hca, hq, hb'⟩ := hk.dec hd hb
    refine .inl ⟨fo, d, BitVec.ofNat 64 k, ws, pre ++ ps ++ [ci], rfl, rfl, ?_, ?_⟩
    · have := hps fun it hit => hx it (by simp [hit])
      simp [Call.callSeq, hhead, this, bind, Option.bind, pure]
    · rw [hkk]; exact ⟨hca, hq, hb'⟩
  | @tail f fo pre ps j ws c'' hhead hd _ hps =>
    have hx := hd.xmmOk
    obtain ⟨hca, hq, hb'⟩ := hk.dec hd hb
    refine .inr ⟨fo, ws, pre ++ ps ++ (fr.epilogue ++ [j]), rfl, rfl, ?_, hca, hq, hb'⟩
    have := hps fun it hit => hx it (by simp [hit])
    simp [Call.tailSeq, hhead, this, bind, Option.bind, pure, Frame.epilogue]

/-! ### Without a frame pointer -/

theorem mapMem_mapMem (f g : M → M) (i : Item) : (i.mapMem f).mapMem g = i.mapMem (g ∘ f) := by
  cases i
  all_goals first
    | rfl
    | (rename_i rm; cases rm <;> rfl)
    | (rename_i rm _; cases rm <;> rfl)

theorem mapMem_eq_self {f : M → M} {i : Item} (h : ∀ m, i.mem? = some m → f m = m) :
    i.mapMem f = i := by
  cases i <;> simp only [Item.mapMem, Item.mem?] at h ⊢
  all_goals first
    | rfl
    | (rw [h _ rfl])
    | (rename_i rm; cases rm <;> simp only [Item.mapMem, Item.mem?] at h ⊢ <;> first | rfl | rw [h _ rfl])
    | (rename_i rm _; cases rm <;> simp only [Item.mapMem, Item.mem?] at h ⊢ <;> first | rfl | rw [h _ rfl])

/-- Without a frame pointer, the item `fromSpFrame` returns is in the encoder's form: its
`spFrame F` is the item read. -/
theorem fromSpFrame_sp {c : Cursor} {F : BitVec 32} {i j : Item} (hsp : c.spFrame = some F)
    (h : c.fromSpFrame i = some j) : j.spFrame F = i := by
  unfold Item.spFrame
  rcases fromSpFrame_cases h with ⟨f, m, hf, hm, hb, rfl⟩ | ⟨rfl, hk⟩
  · rw [hsp] at hf; cases hf
    rw [mapMem_mapMem]
    apply mapMem_eq_self
    intro m' hm'
    rw [hm] at hm'; cases hm'
    simp only [Function.comp, M.frame, beq_self_eq_true, ↓reduceIte]
    cases m; simp only at hb; subst hb
    simp only [M.mk.injEq, true_and]
    exact BitVec.sub_add_cancel _ _
  · apply mapMem_eq_self
    intro m hm
    have hne : m.base ≠ .rbp := fun hb => by rw [(hk m hm).2 hb] at hsp; cases hsp
    simp [hne]

theorem baseOk_spFrame {i : Item} (h : BaseOk i) (F : BitVec 32) : i.spFrame F = i :=
  mapMem_eq_self fun m hm => by rw [h.1] at hm; cases hm

/-- Without a frame pointer, `decodeItem` returns the encoder's form `j` of what it matched:
`j.spFrame F`. -/
theorem decodeItem_matches_sp {c : Cursor} {F : BitVec 32} {j : Item} {n : Nat}
    (hsp : c.spFrame = some F) (h : decodeItem c = some (j, n)) :
    c.matchesItem (j.spFrame F) = some n := by
  have hacc : ∀ (post : Item → Option Item) (i : Item), (∀ k, post i = some k → k.spFrame F = i) →
      c.accept post i = some (j, n) → c.matchesItem (j.spFrame F) = some n := by
    intro post i hp ha
    unfold Cursor.accept at ha
    cases hm : c.matchesItem i <;> cases hq : post i <;> simp only [hm, hq] at ha
    · cases ha
    · cases ha
    · cases ha
    · rename_i n' k
      simp only [Option.some.injEq, Prod.mk.injEq] at ha
      obtain ⟨rfl, rfl⟩ := ha
      rw [hp _ hq]; exact hm
  unfold decodeItem at h
  rcases Option.orElse_some' h with h | h
  · obtain ⟨i, hi, h⟩ := Option.bind_eq_some_iff.mp h
    exact hacc some i (fun k hk => by cases hk; exact baseOk_spFrame (baseCandidate_ok hi) F) h
  · rcases Option.orElse_some' h with h | h <;>
    · obtain ⟨i, -, h⟩ := Option.bind_eq_some_iff.mp h
      exact hacc _ i (fun k hk => fromSpFrame_sp hsp hk) h

/-- Without a frame pointer, the item in memory is `spFrame F` of the one `decodeItem` returns. -/
theorem decodeItem_itemAt_sp {ctx : Ctx} {m : Mem} {c : Cursor} {rs : Array Reloc} {i : Item}
    {n : Nat} {F : BitVec 32} (hf : c.fields = .relocs rs) (hs : Sorted rs)
    (hL : RelocLoaded ctx m c.code rs) (hsz : c.code.size < 2 ^ 32) (hsp : c.spFrame = some F)
    (hb : Boundary rs c.pos) (h : decodeItem c = some (i, n)) :
    ItemAt ctx m (i.spFrame F) c.pos ∧ (i.spFrame F).size = n ∧ c.pos + n ≤ c.code.size ∧
      Boundary rs (c.pos + n) :=
  matchesItem_itemAt hf hs hL hsz hb (decodeItem_matches_sp hsp h)

/-- Without a frame pointer, items read one after the other are in memory in the `spFrame F`
form. -/
theorem codeAt_of_dec_sp {ctx : Ctx} {m : Mem} {c : Cursor} {rs : Array Reloc} {F : BitVec 32}
    (hf : c.fields = .relocs rs) (hs : Sorted rs) (hL : RelocLoaded ctx m c.code rs)
    (hsz : c.code.size < 2 ^ 32) (hsp : c.spFrame = some F) :
    ∀ {p q : Nat} {items : List Item}, Dec c p items q → Boundary rs p →
      CodeAt ctx m (items.map (·.spFrame F)) p ∧ q = p + codeSize (items.map (·.spFrame F)) ∧
        Boundary rs q
  | _, _, _, .nil p, hb => ⟨trivial, by simp [codeSize], hb⟩
  | _, _, _, .cons (p := p) (n := n) (i := i) hd hrest, hb => by
    obtain ⟨hi, hn, -, hb'⟩ := decodeItem_itemAt_sp (c := atPos c p) hf hs hL hsz hsp hb hd
    obtain ⟨hc, hq, hb''⟩ := codeAt_of_dec_sp hf hs hL hsz hsp hrest hb'
    refine ⟨⟨hi, ?_⟩, ?_, hb''⟩
    · rw [hn]; exact hc
    · rw [hq, List.map_cons, codeSize_cons, hn, Nat.add_assoc]

/-- `LinkOk` without a frame pointer: the frame size `F` in the cursor. -/
structure LinkOkSp (ctx : Ctx) (m : Mem) (c : Cursor) (rs : Array Reloc) (F : BitVec 32) :
    Prop where
  fields : c.fields = .relocs rs
  sorted : Sorted rs
  loaded : RelocLoaded ctx m c.code rs
  small : c.code.size < 2 ^ 32
  sp : c.spFrame = some F

theorem LinkOkSp.dec {ctx : Ctx} {m : Mem} {c : Cursor} {rs : Array Reloc} {F : BitVec 32}
    (hk : LinkOkSp ctx m c rs F) {p q : Nat} {items : List Item} (hd : Dec c p items q)
    (hb : Boundary rs p) :
    CodeAt ctx m (items.map (·.spFrame F)) p ∧ q = p + codeSize (items.map (·.spFrame F)) ∧
      Boundary rs q :=
  codeAt_of_dec_sp hk.fields hk.sorted hk.loaded hk.small hk.sp hd hb

theorem LinkOkSp.atPos {ctx : Ctx} {m : Mem} {c : Cursor} {rs : Array Reloc} {F : BitVec 32}
    (hk : LinkOkSp ctx m c rs F) (p : Nat) : LinkOkSp ctx m (atPos c p) rs F :=
  ⟨hk.fields, hk.sorted, hk.loaded, hk.small, hk.sp⟩

end Ryo.Proofs.DecodeLink
