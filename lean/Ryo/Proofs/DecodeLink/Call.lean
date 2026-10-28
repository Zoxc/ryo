/-
Ryo.Proofs.DecodeLink.Call — calls and tail calls as `callInsn` reads them (aot.md §C2, toward
M3 `decode_sound`), against `Ryo.Proofs.Call`'s items.

- `paramItem_int`, `_addr`, `_movd`, `_sse`: each argument load `params` accepts is the
  `Call.paramItem` of the (slot, word) pair it records (the word's `ArgReg.of?` decoded by
  `decide` over the finitely many register indices and sizes).
- `params_read`: `params` reads loads `ps` one after the other, and `Call.paramItems` of its
  words is `ps`, given the loads' `xmm` fields in range (`XmmOk`).
- `resultSeq_read`: the result stores are `resultStores k d` (none: `k = 0`, `d = 0`, no items).
- `callInsn_read` (`CallRead`): a call is `callHead`'s items, the loads, the call and the result
  stores; a tail call `tailHead`'s items, the loads, the epilogue and the jump (`jmp rax` or
  `rex.w jmp rax`: `tailHead`'s `w`, either in any mode).
- `link_call`: in memory (`LinkOk`), with the operands `Call.call_sound` and
  `Call.tail_call_step` take, `callSeq`/`tailSeq` (for some `w`) of them being the items (given
  `XmmOk` of each of those items).

**Hypothesis `XmmOk`.** `params` builds an argument word from an `xmm` load's register number
and size, and from a `movss`/`movsd`/`movups` load's memory operand only its displacement:
the word gives back the decoded item only when the register number is below 8, the size 4, 8
or 16 and the base `rbp`. `decodeItem` returns only such items (`sseCandidate` reads a 3-bit
field and those sizes, `fromSpFrame` rejects `rsp` with a frame pointer, the `movd` parse a
3-bit field), a property of the candidate parsers: `link_call` states `callSeq`/`tailSeq`
under it, and `DecodeLink.Items` discharges it (`decodeItem_xmmOk`, `link_call_ok`).
-/
import Ryo.Proofs.DecodeLink.Links
import Ryo.Proofs.Call

set_option linter.constructorNameAsVariable false
set_option linter.unusedSimpArgs false

namespace Ryo.Proofs.DecodeLink

open Ryo.X86 Ryo.Vm Ryo.Vm.R Ryo.Vm.Asm

theorem int_word_facts : ∀ pe : Bool, ∀ w : W, ∀ i : Fin 6, i.val < (if pe then 4 else 6) →
    let rn := (BitVec.ofNat 32 (ArgReg.mk false (w.bits / 8) i.val).word).toNat
    (rn &&& argAddr != 0) = false ∧ ArgReg.of? rn false = some ⟨false, w.bits / 8, i.val⟩ ∧
      widthOf (w.bits / 8) = w := by
  intro pe w; cases pe <;> cases w <;> decide

theorem paramItem_int (pe : Bool) (w : W) (i : Nat) (hi : i < (if pe then 4 else 6))
    (s : BitVec 32) :
    Call.paramItem pe s (BitVec.ofNat 32 (ArgReg.mk false (w.bits / 8) i).word) =
      some [.ld w false (intArg pe i) (M.frame s)] := by
  have hi6 : i < 6 := by split at hi <;> omega
  obtain ⟨h1, h2, h3⟩ := int_word_facts pe w ⟨i, hi6⟩ hi
  simp only at h1 h2 h3
  unfold Call.paramItem
  simp only [h1, h2, Bool.false_eq_true, ↓reduceIte, hi, h3]

theorem addr_word_facts : ∀ pe : Bool, ∀ i : Fin 6, i.val < (if pe then 4 else 6) →
    let rn := (BitVec.ofNat 32 ((ArgReg.mk false 8 i.val).word ||| argAddr)).toNat
    (rn &&& argAddr != 0) = true ∧ ArgReg.of? (rn - argAddr) false = some ⟨false, 8, i.val⟩ := by
  intro pe; cases pe <;> decide

theorem paramItem_addr (pe : Bool) (i : Nat) (hi : i < (if pe then 4 else 6)) (s : BitVec 32) :
    Call.paramItem pe s (BitVec.ofNat 32 ((ArgReg.mk false 8 i).word ||| argAddr)) =
      some [.leaM (intArg pe i) (M.frame s)] := by
  have hi6 : i < 6 := by split at hi <;> omega
  obtain ⟨h1, h2⟩ := addr_word_facts pe ⟨i, hi6⟩ hi
  simp only at h1 h2
  unfold Call.paramItem
  have hn : ¬ ((if pe then 4 else 6) ≤ i) := by omega
  simp only [h1, h2, ↓reduceIte, hn, Bool.false_eq_true, bne_self_eq_false, Bool.or_false,
    decide_false]

theorem xmm_word_facts : ∀ size : Nat, size = 2 ∨ size = 4 ∨ size = 8 ∨ size = 16 → ∀ x : Fin 8,
    let rn := (BitVec.ofNat 32 (ArgReg.mk true size x.val).word).toNat
    (rn &&& argAddr != 0) = false ∧ ArgReg.of? rn false = some ⟨true, size, x.val⟩ := by
  intro size hs
  rcases hs with rfl | rfl | rfl | rfl <;> decide

theorem paramItem_movd (pe : Bool) (x : Nat) (hx : x < 8) (s : BitVec 32) :
    Call.paramItem pe s (BitVec.ofNat 32 (ArgReg.mk true 2 x).word) =
      some [.ld .w false .r11 (M.frame s), .movd true x .r11] := by
  obtain ⟨h1, h2⟩ := xmm_word_facts 2 (.inl rfl) ⟨x, hx⟩
  simp only at h1 h2
  unfold Call.paramItem
  simp only [h1, h2, Bool.false_eq_true, ↓reduceIte, beq_self_eq_true]

theorem paramItem_sse (pe : Bool) (size x : Nat) (hs : size = 4 ∨ size = 8 ∨ size = 16)
    (hx : x < 8) (s : BitVec 32) :
    Call.paramItem pe s (BitVec.ofNat 32 (ArgReg.mk true size x).word) =
      some [.sse false size x (M.frame s)] := by
  obtain ⟨h1, h2⟩ := xmm_word_facts size (.inr hs) ⟨x, hx⟩
  simp only at h1 h2
  unfold Call.paramItem
  have hs2 : (size == 2) = false := by rcases hs with rfl | rfl | rfl <;> rfl
  simp only [h1, h2, Bool.false_eq_true, ↓reduceIte, hs2]

theorem intIndex_spec {r : X86.Reg} {mode : Mode} {i : Nat} (h : intIndex r mode = some i) :
    i < (if mode.pe then 4 else 6) ∧ intArg mode.pe i = r := by
  unfold intIndex at h
  have h1 := List.find?_some h
  have h2 := List.mem_of_find?_eq_some h
  simp only [beq_iff_eq] at h1
  simp only [List.mem_range] at h2
  exact ⟨h2, h1⟩

theorem paramItems_append (pe : Bool) (s w : BitVec 32) (L : List Item) (hL : Call.paramItem pe s w = some L) :
    ∀ (l : List (BitVec 32)) (ps : List Item), l.length % 2 = 0 → Call.paramItems pe l = some ps →
      Call.paramItems pe (l ++ [s, w]) = some (ps ++ L)
  | [], ps, _, h => by
    simp only [Call.paramItems] at h; cases h
    simp [Call.paramItems, hL, bind, Option.bind, pure]
  | [_], _, h, _ => by simp at h
  | a :: b :: rest, ps, h, hp => by
    simp only [Call.paramItems, bind, Option.bind, pure] at hp ⊢
    cases ha : Call.paramItem pe a b with
    | none => simp [ha] at hp
    | some x =>
      cases hr : Call.paramItems pe rest with
      | none => simp [ha, hr] at hp
      | some y =>
        simp only [ha, hr, Option.some.injEq] at hp
        subst hp
        have := paramItems_append pe s w L hL rest y (by simp at h; omega) hr
        simp only [List.cons_append, Call.paramItems, ha, this, bind, Option.bind, pure,
          List.append_assoc]

/-- An `xmm` item as the decoder parses it: `x` from a 3-bit ModRM field, the size of `movss`,
`movsd` or `movups`, the frame slot off `rbp` (`sseCandidate`, `fromSpFrame` with a frame
pointer). Not proved of `decodeItem` here; the links that need it take it of the items read. -/
def XmmOk : Item → Prop
  | .sse _ size x m => (size = 4 ∨ size = 8 ∨ size = 16) ∧ x < 8 ∧ m.base = .rbp
  | .movd _ x _ => x < 8
  | _ => True

theorem params_read {mode : Mode} {c c' : Cursor} {ws : List (BitVec 32)}
    (h : (params mode).run c = .ok (ws, c')) :
    ∃ ps, Dec c c.pos ps c'.pos ∧ c' = atPos c c'.pos ∧
      ((∀ it ∈ ps, XmmOk it) → Call.paramItems mode.pe ws = some ps) := by
  unfold params at h
  obtain ⟨fu, c1, h1, h⟩ := bind_ok h
  have := fuel_run h1; subst c1
  obtain ⟨st, c2, h2, h⟩ := bind_ok h
  let J : Array (BitVec 32) → Cursor → Prop := fun out cur =>
    out.size % 2 = 0 ∧ ∃ ps, Dec c c.pos ps cur.pos ∧ cur = atPos c cur.pos ∧
      ((∀ it ∈ ps, XmmOk it) → Call.paramItems mode.pe out.toList = some ps)
  let I : Option (List (BitVec 32)) × Array (BitVec 32) → Cursor → Prop := fun st cur =>
    st.1 = none ∧ J st.2 cur
  let D : Option (List (BitVec 32)) × Array (BitVec 32) → Cursor → Prop := fun st cur =>
    st.1 = some st.2.toList ∧ J st.2 cur
  have key := forIn_range_inv I D _ ?step fu (none, #[]) c c2 st
    ⟨rfl, rfl, [], .nil _, rfl, fun _ => rfl⟩ h2
  case step =>
    intro a b cur r cur' hI hr
    obtain ⟨-, hev, ps, hd, hc, hpi⟩ := hI
    obtain ⟨p, c3, h3, hr⟩ := bind_ok hr
    obtain ⟨rfl, hc3⟩ := pos_run' h3
    subst c3
    obtain ⟨nx, c4, h4, hr⟩ := bind_ok hr
    -- what the inner block read
    have inner : (nx = none ∧ c4 = atPos c c4.pos) ∨
        ∃ s w L, nx = some (s, w) ∧ Dec c cur.pos L c4.pos ∧ c4 = atPos c c4.pos ∧
          ((∀ it ∈ L, XmmOk it) → Call.paramItem mode.pe s (BitVec.ofNat 32 w) = some L) := by
      obtain ⟨y, c5, h5, h6⟩ := bind_ok h4
      cases y with
      | none =>
        have := run_tryItem_none h5; subst this
        obtain ⟨rfl, rfl⟩ := pure_ok h6
        exact .inl ⟨rfl, hc⟩
      | some it =>
        obtain ⟨n, hn, rfl⟩ := run_tryItem_some h5
        rw [hc] at hn
        have hframe : ∀ mm : M, (mm.base == X86.Reg.rbp) = true → M.frame mm.disp = mm := by
          intro mm hm; cases mm; simp only [beq_iff_eq] at hm; subst hm; rfl
        split at h6
        · -- ld
          rename_i w dst mm heq
          cases heq
          split at h6
          · rename_i i hi
            obtain ⟨hil, hia⟩ := intIndex_spec hi
            split at h6
            · rename_i hb
              obtain ⟨rfl, rfl⟩ := pure_ok h6
              refine .inr ⟨_, _, [.ld w false dst mm], rfl, ?_, ?_, fun _ => ?_⟩
              · exact Dec.single hn
              · rw [hc]
              · rw [paramItem_int _ _ _ hil, hia, hframe mm hb]
            · obtain ⟨rfl, rfl⟩ := pure_ok h6
              exact .inl ⟨rfl, by rw [hc]⟩
          · split at h6
            · rename_i hcond
              simp only [Bool.and_eq_true, beq_iff_eq] at hcond
              obtain ⟨⟨rfl, rfl⟩, hb⟩ := hcond
              obtain ⟨y2, c7, h7, h8⟩ := bind_ok h6
              cases y2 with
              | none =>
                have := run_tryItem_none h7; subst this
                obtain ⟨rfl, rfl⟩ := pure_ok h8
                exact .inl ⟨rfl, by rw [hc]⟩
              | some it2 =>
                obtain ⟨n2, hn2, rfl⟩ := run_tryItem_some h7
                split at h8
                · rename_i x heq2
                  cases heq2
                  obtain ⟨rfl, rfl⟩ := pure_ok h8
                  refine .inr ⟨_, _, [.ld .w false .r11 mm, .movd true x .r11], rfl, ?_, ?_, fun hx => ?_⟩
                  · rw [hc] at hn2
                    exact (Dec.single hn).append (Dec.single hn2)
                  · rw [hc]
                  · rw [paramItem_movd _ _ (hx (.movd true x .r11) (by simp)), hframe mm (by simpa using hb)]
                · obtain ⟨rfl, rfl⟩ := pure_ok h8
                  exact .inl ⟨rfl, by rw [hc]⟩
            · obtain ⟨rfl, rfl⟩ := pure_ok h6
              exact .inl ⟨rfl, by rw [hc]⟩
        · -- leaM
          rename_i dst mm heq
          cases heq
          split at h6
          · rename_i i hi
            obtain ⟨hil, hia⟩ := intIndex_spec hi
            split at h6
            · rename_i hb
              obtain ⟨rfl, rfl⟩ := pure_ok h6
              refine .inr ⟨_, _, [.leaM dst mm], rfl, Dec.single hn, by rw [hc], fun _ => ?_⟩
              rw [paramItem_addr _ _ hil, hia, hframe mm hb]
            · obtain ⟨rfl, rfl⟩ := pure_ok h6
              exact .inl ⟨rfl, by rw [hc]⟩
          · obtain ⟨rfl, rfl⟩ := pure_ok h6
            exact .inl ⟨rfl, by rw [hc]⟩
        · -- sse
          rename_i size x mm heq
          cases heq
          obtain ⟨rfl, rfl⟩ := pure_ok h6
          refine .inr ⟨_, _, [.sse false size x mm], rfl, Dec.single hn, by rw [hc], fun hx => ?_⟩
          obtain ⟨hs, hx8, hb⟩ := hx (.sse false size x mm) (by simp)
          rw [paramItem_sse _ _ _ hs hx8, hframe mm (by simpa using hb)]
        · obtain ⟨rfl, rfl⟩ := pure_ok h6
          exact .inl ⟨rfl, by rw [hc]⟩
    rcases inner with ⟨rfl, hc4⟩ | ⟨s, w, L, rfl, hdL, hc4, hL⟩
    · simp only at hr
      obtain ⟨u, c5, h5, hr⟩ := bind_ok hr
      rw [run_setPos] at h5; cases h5
      obtain ⟨rfl, rfl⟩ := pure_ok hr
      refine ⟨rfl, hev, ps, hd, ?_, hpi⟩
      rw [hc4, hc]
    · simp only at hr
      obtain ⟨rfl, rfl⟩ := pure_ok hr
      refine ⟨rfl, by simp; omega, ps ++ L, ?_, hc4, fun hx => ?_⟩
      · rw [hc] at hdL; exact hd.append (Dec.at_iff.mp hdL)
      · simp only [Array.toList_push, List.append_assoc, List.singleton_append]
        apply paramItems_append _ _ _ _ (hL fun it hit => hx it (by simp [hit])) _ _ (by simpa using hev)
        exact hpi fun it hit => hx it (by simp [hit])
  rcases key with ⟨hn, hev, ps, hd, hc, hpi⟩ | ⟨hs, hev, ps, hd, hc, hpi⟩
  · dsimp only at h; rw [hn] at h; dsimp only at h
    obtain ⟨rfl, rfl⟩ := pure_ok h
    exact ⟨ps, hd, hc, hpi⟩
  · dsimp only at h; rw [hs] at h; dsimp only at h
    obtain ⟨rfl, rfl⟩ := pure_ok h
    exact ⟨ps, hd, hc, hpi⟩

theorem resultStores_zero : resultStores 0 0 = [] := by decide

theorem retKind_lt (parts : List RetPart) : retKind parts < 2 ^ 32 := by
  unfold retKind; split <;> simp [u32] <;> omega

/-- A call's result stores as `resultSeq` reads them (none: slot 0, kind 0). -/
theorem resultSeq_read {c c' : Cursor} {d : BitVec 32} {k : Nat}
    (h : resultSeq.run c = .ok ((d, k), c')) :
    Dec c c.pos (resultStores k d) c'.pos ∧ c' = atPos c c'.pos ∧ k < 2 ^ 32 := by
  unfold resultSeq at h
  obtain ⟨at_, c1, h1, h⟩ := bind_ok h
  obtain ⟨rfl, hc1⟩ := pos_run' h1
  subst c1
  obtain ⟨items, c2, h2, h⟩ := bind_ok h
  obtain ⟨d2, e2, -⟩ := take_dec h2
  have jp : ∀ c3, c3 = atPos c c3.pos →
      (do DM.setPos c.pos; pure (0, 0) : DM (BitVec 32 × Nat)).run c3 = .ok ((d, k), c') →
      Dec c c.pos (resultStores k d) c'.pos ∧ c' = atPos c c'.pos ∧ k < 2 ^ 32 := by
    intro c3 hc3 h3
    obtain ⟨u, c4, h4, h5⟩ := bind_ok h3
    rw [run_setPos] at h4; cases h4
    simp only [StateT.run, pure, StateT.pure, Except.pure, Except.ok.injEq, Prod.mk.injEq] at h5
    obtain ⟨⟨rfl, rfl⟩, rfl⟩ := h5
    refine ⟨?_, by rw [hc3], by decide⟩
    rw [resultStores_zero]; exact .nil _
  dsimp only at h
  split at h
  · rename_i d' parts _
    split at h
    · rename_i hc
      obtain ⟨he, rfl⟩ := pure_ok h
      cases he
      simp only [Bool.and_eq_true, beq_iff_eq] at hc
      refine ⟨?_, e2, retKind_lt _⟩
      rw [hc.2]; exact d2
    · exact jp _ e2 h
  · exact jp _ e2 h

/-- The items before a call's argument loads (`callInsn`'s `pre`). -/
def preItems : Pre → List Item
  | .none => []
  | .sym s => [.loadRip .rax (.sym s)]
  | .ptr p => [.ld .q false .rax (M.frame p)]

/-- The proto of a call: `ops` the result slot, the callee, the result kind, the argument
words. -/
abbrev callProto (f : Full.Opcode) (fo : Opnd Nat) (d : BitVec 32) (k : Nat) (ws : List (BitVec 32))
    (p : Nat) (site : Nat × Nat) : Proto :=
  { op := f, ops := [.slot d, fo, .imm (BitVec.ofNat 64 k), .words ws], pos := p, sites := [site], bare := k == 0 }

/-- What `callInsn` read: a call (`Call.callSeq`'s items, then the result stores) or a tail call
(`Call.tailSeq`'s), with the operands `Call.call_sound` / `Call.tail_call_step` take. -/
inductive CallRead (fr : Frame) (c : Cursor) : Proto → Cursor → Prop
  | call {f : Full.Opcode} {fo : Opnd Nat} {pre ps : List Item} {ci : Item} {ws : List (BitVec 32)}
      {d : BitVec 32} {k : Nat} {site : Nat × Nat} {c' : Cursor} :
      Call.callHead f fo = some (pre, ci) →
      Dec c c.pos (pre ++ ps ++ [ci] ++ resultStores k d) c'.pos → c' = atPos c c'.pos →
      ((∀ it ∈ ps, XmmOk it) → Call.paramItems fr.mode.pe ws = some ps) → k < 2 ^ 32 →
      CallRead fr c (callProto f fo d k ws c.pos site) c'
  | tail {w : Bool} {f : Full.Opcode} {fo : Opnd Nat} {pre ps : List Item} {j : Item}
      {ws : List (BitVec 32)} {c' : Cursor} :
      Call.tailHead w f fo = some (pre, j) →
      Dec c c.pos (pre ++ ps ++ (fr.epilogue ++ [j])) c'.pos → c' = atPos c c'.pos →
      ((∀ it ∈ ps, XmmOk it) → Call.paramItems fr.mode.pe ws = some ps) →
      CallRead fr c { op := f, ops := [fo, .words ws], pos := c.pos } c'

set_option maxRecDepth 100000 in
theorem symInd_ne : (Full.Opcode.callSymInd == Full.Opcode.callSym) = false := by decide

theorem head_call (g : Nat) : Call.callHead .call (.func g) = some (preItems .none, .call (.func g)) := by
  simp [Call.callHead, preItems]
theorem head_callSym (s : Nat) :
    Call.callHead .callSym (.sym s) = some (preItems .none, .callMem (.sym s)) := by
  simp [Call.callHead, preItems]
theorem head_callSymInd (s : Nat) :
    Call.callHead .callSymInd (.sym s) = some (preItems (.sym s), .callMemRax) := by
  simp [Call.callHead, preItems, symInd_ne]
theorem head_callPtr (p : BitVec 32) :
    Call.callHead .callPtr (.slot p) = some (preItems (.ptr p), .callRax) := by
  simp [Call.callHead, preItems]
theorem head_tailCall (w : Bool) (g : Nat) :
    Call.tailHead w .tailCall (.func g) = some (preItems .none, .jmp (.func g)) := by
  simp [Call.tailHead, preItems]
theorem head_tailCallPtr (w : Bool) (p : BitVec 32) :
    Call.tailHead w .tailCallPtr (.slot p) = some (preItems (.ptr p), Call.jmpRaxOf w) := by
  simp [Call.tailHead, preItems]

set_option maxRecDepth 100000 in
theorem callInsn_read {fr : Frame} {dropped : List DroppedStore} {c c' : Cursor} {q : Proto}
    (h : (callInsn fr dropped).run c = .ok (some q, c')) : CallRead fr c q c' := by
  unfold callInsn at h
  obtain ⟨p0, c1, h1, h⟩ := bind_ok h
  obtain ⟨rfl, hc1⟩ := pos_run' h1
  subst c1
  obtain ⟨pr, c2, h2, h⟩ := bind_ok h
  have hpre : Dec c c.pos (preItems pr) c2.pos ∧ c2 = atPos c c2.pos := by
    obtain ⟨y, c7, h7, h8⟩ := bind_ok h2
    cases y with
    | none =>
      have := run_tryItem_none h7; subst this
      obtain ⟨u, c9, h9, h10⟩ := bind_ok h8
      rw [run_setPos] at h9; cases h9
      obtain ⟨rfl, rfl⟩ := pure_ok h10
      exact ⟨.nil _, rfl⟩
    | some it =>
      obtain ⟨n, hn, rfl⟩ := run_tryItem_some h7
      split at h8
      · rename_i s heq; cases heq
        obtain ⟨rfl, rfl⟩ := pure_ok h8
        exact ⟨Dec.single hn, rfl⟩
      · rename_i mm heq; cases heq
        split at h8
        · rename_i hb
          obtain ⟨rfl, rfl⟩ := pure_ok h8
          have : M.frame mm.disp = mm := by cases mm; simp only [beq_iff_eq] at hb; subst hb; rfl
          refine ⟨?_, rfl⟩
          simp only [preItems, this]; exact Dec.single hn
        · obtain ⟨u, c9, h9, h10⟩ := bind_ok h8
          rw [run_setPos] at h9; cases h9
          obtain ⟨rfl, rfl⟩ := pure_ok h10
          exact ⟨.nil _, rfl⟩
      · obtain ⟨u, c9, h9, h10⟩ := bind_ok h8
        rw [run_setPos] at h9; cases h9
        obtain ⟨rfl, rfl⟩ := pure_ok h10
        exact ⟨.nil _, rfl⟩
  obtain ⟨dpre, epre⟩ := hpre
  obtain ⟨ws, c3, h3, h⟩ := bind_ok h
  obtain ⟨ps, dps, eps, hps⟩ := params_read h3
  rw [epre] at dps
  have dpp := dpre.trans' dps
  have eps' : c3 = atPos c c3.pos := eps.trans (by rw [epre])
  obtain ⟨callAt, c4, h4, h⟩ := bind_ok h
  obtain ⟨rfl, hc4⟩ := pos_run' h4
  subst c4
  split at h
  · obtain ⟨u, c9, -, h10⟩ := bind_ok h
    obtain ⟨he, -⟩ := pure_ok h10; cases he
  dsimp only at h
  obtain ⟨it, c5, h5, h⟩ := bind_ok h
  obtain ⟨r, c6, h6, h⟩ := bind_ok h
  have hnone : r = none → False := by
    intro hr; subst hr
    obtain ⟨u, c9, -, h10⟩ := bind_ok h
    obtain ⟨he, -⟩ := pure_ok h10; cases he
  have fin_call : ∀ f fo ci n, Call.callHead f fo = some (preItems pr, ci) →
      decodeItem c3 = some (ci, n) → r = some (f, [fo], true) → c6 = atPos c3 (c3.pos + n) →
      CallRead fr c q c' := by
    intro f fo ci n hhead hn hr hc6
    subst hr hc6
    dsimp only at h
    obtain ⟨x, c7, h7, h⟩ := bind_ok h
    obtain ⟨rfl, hc7⟩ := pos_run' h7
    subst c7
    obtain ⟨⟨d, k⟩, c8, h8, h⟩ := bind_ok h
    obtain ⟨he, rfl⟩ := pure_ok h
    cases he
    obtain ⟨d8, e8, hk⟩ := resultSeq_read h8
    refine .call hhead ?_ ?_ hps hk
    · rw [eps'] at hn d8
      have := (dpp.append (Dec.single hn)).trans' (Dec.at_iff.mpr (Dec.at_iff.mp d8))
      simpa using this
    · rw [e8, eps']
  have fin_tail : ∀ w f fo j (cE : Cursor) n2, Call.tailHead w f fo = some (preItems pr, j) →
      Dec c c3.pos fr.epilogue cE.pos → cE = atPos c cE.pos →
      decodeItem cE = some (j, n2) →
      r = some (f, [fo, .words ws], false) → c6 = atPos cE (cE.pos + n2) →
      CallRead fr c q c' := by
    intro w f fo j cE n2 hhead dE eE hn2 hr hc6
    subst hr hc6
    dsimp only at h
    obtain ⟨he, rfl⟩ := pure_ok h
    cases he
    refine .tail hhead ?_ ?_ hps
    · rw [eE] at hn2
      have := (dpp.append dE).append (Dec.single hn2)
      simpa using this
    · rw [eE]
  split at h6
  · obtain ⟨rfl, rfl⟩ := pure_ok h6
    obtain ⟨n, hn, rfl⟩ := run_tryItem_some h5
    exact fin_call _ _ _ n (head_call _) hn rfl rfl
  · obtain ⟨rfl, rfl⟩ := pure_ok h6
    obtain ⟨n, hn, rfl⟩ := run_tryItem_some h5
    exact fin_call _ _ _ n (head_callSym _) hn rfl rfl
  · obtain ⟨rfl, rfl⟩ := pure_ok h6
    obtain ⟨n, hn, rfl⟩ := run_tryItem_some h5
    exact fin_call _ _ _ n (head_callSymInd _) hn rfl rfl
  · obtain ⟨rfl, rfl⟩ := pure_ok h6
    obtain ⟨n, hn, rfl⟩ := run_tryItem_some h5
    exact fin_call _ _ _ n (head_callPtr _) hn rfl rfl
  · -- A tail call: the epilogue and the jump, read again from `callAt`.
    have e5 : c5 = atPos c3 c5.pos := posOnly_run PosOnly.tryItem h5
    obtain ⟨u, c7, h7, h6⟩ := bind_ok h6
    rw [run_setPos] at h7; cases h7
    have hc3 : atPos c5 c3.pos = c3 := by rw [e5]
    rw [hc3] at h6
    obtain ⟨b, cE, hE, h6⟩ := bind_ok h6
    split at h6
    · obtain ⟨rfl, rfl⟩ := pure_ok h6
      exact (hnone rfl).elim
    rename_i hb
    have hb : b = true := by simpa using hb
    subst hb
    obtain ⟨dE, eE⟩ := expectItems_dec hE
    have dE' : Dec c c3.pos fr.epilogue cE.pos := by
      obtain ⟨p3, rfl⟩ : ∃ p, c3 = atPos c p := ⟨_, eps'⟩
      exact Dec.at_iff.mp dE
    have eE' : cE = atPos c cE.pos := by rw [eE, eps']
    obtain ⟨y, c8, h8, h6⟩ := bind_ok h6
    split at h6
    · obtain ⟨rfl, rfl⟩ := pure_ok h6
      obtain ⟨n2, hn2, rfl⟩ := run_tryItem_some h8
      exact fin_tail false _ _ _ cE n2 (head_tailCall false _) dE' eE' hn2 rfl rfl
    · obtain ⟨rfl, rfl⟩ := pure_ok h6
      obtain ⟨n2, hn2, rfl⟩ := run_tryItem_some h8
      exact fin_tail false _ _ _ cE n2 (head_tailCallPtr false _) dE' eE' hn2 rfl rfl
    · obtain ⟨rfl, rfl⟩ := pure_ok h6
      obtain ⟨n2, hn2, rfl⟩ := run_tryItem_some h8
      exact fin_tail true _ _ _ cE n2 (head_tailCallPtr true _) dE' eE' hn2 rfl rfl
    · obtain ⟨rfl, rfl⟩ := pure_ok h6
      exact (hnone rfl).elim

/-- A call the decoder read at `c.pos` (`callInsn`): `Call.callSeq`'s items (given the argument
loads' `xmm` fields in range, `XmmOk`), then the result stores, with the operands
`Call.call_sound` takes (`[.slot d, fo, .imm k, .words ws]`); or a tail call, `Call.tailSeq`'s
items for the frame size `fr.size` and the jump's `w`, operands `[fo, .words ws]`
(`Call.tail_call_step`). -/
theorem link_call {ctx : Ctx} {m : Mem} {c c' : Cursor} {rs : Array Reloc} {fr : Frame}
    {dropped : List DroppedStore} {q : Proto} (hk : LinkOk ctx m c rs) (hb : Boundary rs c.pos)
    (h : (callInsn fr dropped).run c = .ok (some q, c')) :
    (∃ (fo : Opnd Nat) (d : BitVec 32) (k : BitVec 64) (ws : List (BitVec 32)) (items : List Item),
      q.ops = [.slot d, fo, .imm k, .words ws] ∧ q.handler = none ∧
      ((∀ it ∈ items, XmmOk it) → Call.callSeq fr.mode.pe q.op fo ws = some items) ∧
      CodeAt ctx m (items ++ resultStores k.toNat d) c.pos ∧
      c'.pos = c.pos + codeSize (items ++ resultStores k.toNat d) ∧ Boundary rs c'.pos) ∨
    (∃ (fo : Opnd Nat) (ws : List (BitVec 32)) (items : List Item),
      q.ops = [fo, .words ws] ∧ q.handler = none ∧
      ((∀ it ∈ items, XmmOk it) → ∃ w, Call.tailSeq fr.size fr.mode w q.op fo ws = some items) ∧
      CodeAt ctx m items c.pos ∧ c'.pos = c.pos + codeSize items ∧ Boundary rs c'.pos) := by
  cases callInsn_read h with
  | @call f fo pre ps ci ws d k site c'' hhead hd _ hps hk32 =>
    have hkk : (BitVec.ofNat 64 k).toNat = k := by
      rw [BitVec.toNat_ofNat]; exact Nat.mod_eq_of_lt (by omega)
    obtain ⟨hca, hq, hb'⟩ := hk.dec hd hb
    refine .inl ⟨fo, d, BitVec.ofNat 64 k, ws, pre ++ ps ++ [ci], rfl, rfl, fun hx => ?_, ?_⟩
    · have := hps fun it hit => hx it (by simp [hit])
      simp [Call.callSeq, hhead, this, bind, Option.bind, pure]
    · rw [hkk]; exact ⟨hca, hq, hb'⟩
  | @tail w f fo pre ps j ws c'' hhead hd _ hps =>
    obtain ⟨hca, hq, hb'⟩ := hk.dec hd hb
    refine .inr ⟨fo, ws, pre ++ ps ++ (fr.epilogue ++ [j]), rfl, rfl, fun hx => ⟨w, ?_⟩, hca, hq,
      hb'⟩
    have := hps fun it hit => hx it (by simp [hit])
    simp [Call.tailSeq, hhead, this, bind, Option.bind, pure, Frame.epilogue]

end Ryo.Proofs.DecodeLink
