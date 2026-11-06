/-
Ryo.Proofs.DeadStore.DropForm — the dropped stores the decoder records against the R operation's
destination (`Frame.droppedStore`, `Frame.flagSlot`): Sim.lean's `dinline_dropW`, `dinline_flag`,
`dinline_opSem_frame` (DS-T9), as `dropForm_dropW`, `dropForm_flag`, `dropForm_opSem_frame`.

**The missing link (a decoder fact, `DroppedAgree`).** `Frame.droppedStore d k` is the `"d"`
slot of instruction `k` at a width read off its *mnemonic* (`fixedDestWidth`, `secondWidth`,
`widthOfMnemonic`, `mov.w128` ↦ 8, …), while the store the decoder drops is an item of
`cache.emit (sequence cls ops)` (`inlineInsn_erased_dropped`: `out[i]? = some d.item`), of the
width the class's sequence gives it. Nothing the decoder checks ties the two:
- the width: a per-opcode table fact, `(f, cls) ∈ inlineOps → ` the mnemonic width of `f` is the
  width of `cls`'s final store to slot 0 (`outSize cls`, but 8 for `mov128`'s low half);
- the position: which emitted store is dropped. `inlineInsn` drops whatever item sits at a
  recorded `DroppedStore.at_`; for `mov128` (two stores, `[d + 8]` then `[d]`) or an overflow op
  (result store, then the flag's `mov [o], cl`) only the last store to `[d]` matches
  `droppedStore`'s range.

Proposed Lean-only check (decoder side, `DecodeReduced.inlineInsn`'s `accept`, or after
`reducedOf` in `decodeChecked`): when `wasDropped`, require that the erased item
`its[dropAt]` is `.st w r (M.frame s)` with `(s, w.bits / 8) = droppedStore` of the instruction
it decodes to (equivalently: `Asm.frameWrite its[dropAt] = some (M.frame s, n)` with
`Frame.droppedStore d k = some (s, n)`). The width half alone is a finite table check over
`inlineOps` (`decide`, as `inline_ofFullTable`). `DroppedAgree` below states what that check
gives, for the stores consumed at `k`.
-/
import Ryo.Proofs.DeadStore.PtrLive
import Ryo.Proofs.CacheEmitRanges

set_option linter.constructorNameAsVariable false

/-! ### Write ranges, slot operands and `emit`'s frame stores (DS-T9 helpers)

In `CacheStep`'s namespace and opens (as `CacheEmitRanges.lean`). -/

namespace Ryo.Proofs.CacheStep

open Ryo.Spec Ryo.Vm Ryo.Vm.OpSem Ryo.X86 Ryo.Vm.Asm Ryo.Proofs.Inline Ryo.Proofs.Scope
  Ryo.Proofs.Step Ryo.Proofs.RegCache

/-- (d) A `"d"` slot first operand is a slot in `ops`. -/
theorem ops0_slot {ρ : R.Addrs} {f : Full.Opcode} {ops : List (R.Opnd Nat)} {vals : Operands}
    {rest : List OperandInfo} (ho : f.info.operands = ⟨"d", .slot⟩ :: rest)
    (hn : nativeVals ρ f ops = some vals) : ∃ s, ops[0]? = some (.slot s) := by
  rcases ops with _ | ⟨o0, os⟩
  · unfold nativeVals at hn
    rw [ho] at hn
    simp at hn
  unfold nativeVals at hn
  rw [ho] at hn
  split at hn
  · simp only [List.zip_cons_cons, List.mapM_cons, Option.bind_eq_bind, Option.bind_eq_some_iff,
      Option.pure_def, Option.some.injEq] at hn
    obtain ⟨v0, h0', -⟩ := hn
    obtain ⟨s', rfl, -⟩ := nv_slot.1 h0'
    exact ⟨s', rfl⟩
  · cases hn

/-- (d) An `"o"` slot second operand (`ovf`, `mul.ovf`) is a slot in `ops`. -/
theorem ops1_slot {ρ : R.Addrs} {f : Full.Opcode} {ops : List (R.Opnd Nat)} {vals : Operands}
    {rest : List OperandInfo} (ho : f.info.operands = ⟨"d", .slot⟩ :: ⟨"o", .slot⟩ :: rest)
    (hn : nativeVals ρ f ops = some vals) : ∃ s, ops[1]? = some (.slot s) := by
  rcases ops with _ | ⟨o0, _ | ⟨o1, os⟩⟩
  · unfold nativeVals at hn
    rw [ho] at hn
    simp at hn
  · unfold nativeVals at hn
    rw [ho] at hn
    simp at hn
  unfold nativeVals at hn
  rw [ho] at hn
  split at hn
  · simp only [List.zip_cons_cons, List.mapM_cons, Option.bind_eq_bind, Option.bind_eq_some_iff,
      Option.pure_def, Option.some.injEq] at hn
    obtain ⟨v0, -, vs, ⟨v1, h1', -⟩, -⟩ := hn
    obtain ⟨s', rfl, -⟩ := nv_slot.1 h1'
    exact ⟨s', rfl⟩
  · cases hn

set_option hygiene false in
/-- `wranges_cases`' close for a footprint writing only `rdA "d" n`. -/
macro "wr_d" : tactic =>
  `(tactic| (
    obtain ⟨s, h0⟩ := ops0_slot ho hn
    simp [Footprint.writeRanges, Access.range, vals_d ho hn h0, Val.slotOff, Extent.eval] at hr
    subst hr
    exact .inl ⟨s, h0, rfl⟩))

set_option hygiene false in
/-- `wranges_cases`' close for an overflow footprint (`rdA "d" n`, `rdA "o" 1`). -/
macro "wr_o" : tactic =>
  `(tactic| (
    obtain ⟨s, h0⟩ := ops0_slot ho hn
    obtain ⟨so, h1⟩ := ops1_slot ho hn
    simp [Footprint.writeRanges, Access.range, vals_d ho hn h0, vals_o ho hn h1, Val.slotOff,
      Extent.eval] at hr
    rcases hr with hr | hr <;> subst hr
    · exact .inl ⟨s, h0, rfl⟩
    · exact .inr ⟨rfl, so, h1, rfl⟩))

set_option hygiene false in
/-- `wranges_cases`' close for a footprint writing nothing. -/
macro "wr_none" : tactic =>
  `(tactic| (simp [Footprint.writeRanges] at hr))

/-- (a) The write ranges are exactly the class's destination range `(d, outSize cls)` and an
overflow class's flag range `(o, 1)` (the converse of `wranges_out`, `wranges_flag`). -/
theorem wranges_cases {ρ : R.Addrs} {f : Full.Opcode} {cls : Class} {ops : List (R.Opnd Nat)}
    {vals : Operands} {r : Int × Nat} (hs : shapeOk f cls = true)
    (hn : nativeVals ρ f ops = some vals) (hr : r ∈ wranges f vals) :
    (∃ s, ops[0]? = some (.slot s) ∧ r = (s.toInt, outSize cls)) ∨
      (isOvf cls = true ∧ ∃ s, ops[1]? = some (.slot s) ∧ r = (s.toInt, 1)) := by
  obtain ⟨⟨r', hh⟩, ho⟩ := shapeOk_spec hs
  unfold wranges at hr
  cases cls with
  | mov w =>
    simp only [classHandler, classOperands] at hh ho
    rw [footprint_eq hh] at hr
    rw [(fp_w (tySize_tyName _ _)).1] at hr; wr_d
  | mov128 =>
    simp only [classHandler, classOperands] at hh ho
    rw [footprint_eq hh] at hr
    rw [(fp_w (ps := []) (ty := "u128") (n := 16) rfl).1] at hr; wr_d
  | imm w =>
    simp only [classHandler, classOperands] at hh ho
    rw [footprint_eq hh] at hr
    rw [(fp_w (tySize_tyName _ _)).2.1] at hr; wr_d
  | addr =>
    simp only [classHandler, classOperands] at hh ho
    rw [footprint_eq hh] at hr
    rw [fp_addr] at hr; wr_d
  | addrConst =>
    simp only [classHandler, classOperands] at hh ho
    rw [footprint_eq hh] at hr
    rw [fp_addr_const] at hr; wr_d
  | addrSym =>
    simp only [classHandler, classOperands] at hh ho
    rw [footprint_eq hh] at hr
    obtain ⟨de, hde⟩ := fpAddrSym "false"
    rw [hde] at hr; wr_d
  | addrSymInd =>
    simp only [classHandler, classOperands] at hh ho
    rw [footprint_eq hh] at hr
    obtain ⟨de, hde⟩ := fpAddrSym "true"
    rw [hde] at hr; wr_d
  | ptrAdd =>
    simp only [classHandler, classOperands] at hh ho
    rw [footprint_eq hh] at hr
    rw [fp_ptr_add] at hr; wr_d
  | ptrIndex =>
    simp only [classHandler, classOperands] at hh ho
    rw [footprint_eq hh] at hr
    rw [fp_ptr_index] at hr; wr_d
  | load w =>
    simp only [classHandler, classOperands] at hh ho
    rw [footprint_eq hh] at hr
    rw [(fp_load (tySize_tyName _ _)).1] at hr; wr_d
  | store w =>
    simp only [classHandler, classOperands] at hh ho
    rw [footprint_eq hh] at hr
    rw [(fp_load (tySize_tyName _ _)).2] at hr; wr_none
  | bin op w =>
    cases op <;> simp only [classHandler, classOperands, aluKind, Bool.false_eq_true,
      ↓reduceIte] at hh ho <;>
      (rw [footprint_eq hh] at hr) <;>
      (first | rw [(fp_w (tySize_tyName _ _)).2.2.1] at hr | rw [(fp_w (tySize_tyName _ _)).2.2.2.1] at hr) <;>
      wr_d
  | binImm op w =>
    cases op <;> simp only [classHandler, classOperands, aluKind, ↓reduceIte] at hh ho <;>
      (rw [footprint_eq hh] at hr) <;>
      (first | rw [(fp_w (tySize_tyName _ _)).2.2.2.2.1] at hr | rw [(fp_w (tySize_tyName _ _)).2.2.2.2.2.1] at hr) <;>
      wr_d
  | mul w =>
    simp only [classHandler, classOperands] at hh ho
    rw [footprint_eq hh] at hr
    rw [(fp_w (tySize_tyName _ _)).2.2.1] at hr; wr_d
  | mulImm w =>
    simp only [classHandler, classOperands] at hh ho
    rw [footprint_eq hh] at hr
    rw [(fp_w (tySize_tyName _ _)).2.2.2.2.1] at hr; wr_d
  | shiftImm sh w =>
    simp only [classHandler, classOperands] at hh ho
    rw [footprint_eq hh] at hr
    rw [(fp_w (tySize_tyName _ _)).2.2.2.2.2.2.1] at hr; wr_d
  | cmp c w =>
    simp only [classHandler, classOperands, cmpParams] at hh ho
    rw [footprint_eq hh] at hr
    rw [(fp_w (tySize_tyName _ _)).2.2.2.2.2.2.2.1] at hr; wr_d
  | cmpImm c w =>
    simp only [classHandler, classOperands, cmpParams] at hh ho
    rw [footprint_eq hh] at hr
    rw [(fp_w (tySize_tyName _ _)).2.2.2.2.2.2.2.2.1] at hr; wr_d
  | br =>
    simp only [classHandler, classOperands] at hh ho
    rw [footprint_eq hh] at hr
    rw [fp_br] at hr; wr_none
  | brCmp c w =>
    simp only [classHandler, classOperands, cmpParams] at hh ho
    rw [footprint_eq hh] at hr
    rw [(fp_w (tySize_tyName _ _)).2.2.2.2.2.2.2.2.2.1] at hr; wr_none
  | brCmpImm c w =>
    simp only [classHandler, classOperands, cmpParams] at hh ho
    rw [footprint_eq hh] at hr
    rw [(fp_w (tySize_tyName _ _)).2.2.2.2.2.2.2.2.2.2] at hr; wr_none
  | ovf op sg w =>
    simp only [classHandler, classOperands] at hh ho
    rw [footprint_eq hh] at hr
    rw [fp_ovf (tySize_tyName _ _)] at hr; wr_o
  | mulOvf sg w =>
    simp only [classHandler, classOperands] at hh ho
    rw [footprint_eq hh] at hr
    rw [fp_ovf (tySize_tyName _ _)] at hr; wr_o
  | ext src dst sx =>
    simp only [classHandler, classOperands] at hh ho
    rw [footprint_eq hh] at hr
    rw [fp_cvt (tySize_tyName _ _) (tySize_tyName _ _)] at hr; wr_d
  | shiftVar sh w =>
    cases sh <;> simp only [classHandler, classOperands] at hh ho <;>
      (rw [footprint_eq hh] at hr) <;>
      (first | rw [Later.fp_shift (tySize_tyName _ _)] at hr | rw [Later.fp_rot (tySize_tyName _ _)] at hr) <;>
      wr_d
  | div sg rem w =>
    simp only [classHandler, classOperands] at hh ho
    rw [footprint_eq hh] at hr
    rw [fpBinFn (tySize_tyName _ _)] at hr; wr_d
  | count lz w =>
    simp only [classHandler, classOperands] at hh ho
    rw [footprint_eq hh] at hr
    rw [fpCount (tySize_tyName _ _)] at hr; wr_d
  | cmp3 sg w =>
    simp only [classHandler, classOperands] at hh ho
    rw [footprint_eq hh] at hr
    rw [Later.fp_cmp3 (tySize_tyName _ _)] at hr; wr_d
  | bswap w =>
    simp only [classHandler, classOperands] at hh ho
    rw [footprint_eq hh] at hr
    rw [Later.fp_un (tySize_tyName _ _)] at hr; wr_d

/-- `emit`'s loop keeps what it pushed. -/
theorem emitFold_mono (xr : Reg) : ∀ (rest : List Item) (st : Cache × Array Item),
    ∀ e ∈ st.2.toList, e ∈ (rest.foldl (emitStep xr) st).2.toList
  | [], _, _, he => he
  | it :: rest, st, e, he => by
    obtain ⟨e', c', heq, -⟩ := emitStep_cases xr st it
    simp only [List.foldl_cons, heq]
    exact emitFold_mono xr rest _ e (by simp [Array.toList_push, he])

/-- `emit`'s loop pushes, for each item, one with its renamed write. -/
theorem emitFold_writes (xr : Reg) : ∀ (rest : List Item) (st : Cache × Array Item),
    ∀ it ∈ rest, ∃ e ∈ (rest.foldl (emitStep xr) st).2.toList, writeOf e = writeOf (ren xr it)
  | [], _, _, hi => nomatch hi
  | it :: rest, st, i, hi => by
    obtain ⟨e', c', heq, hcase⟩ := emitStep_cases xr st it
    simp only [List.foldl_cons, heq]
    rcases List.mem_cons.1 hi with rfl | hi
    · refine ⟨e', emitFold_mono xr rest _ e' (by simp [Array.toList_push]), ?_⟩
      rcases hcase with ⟨rfl, -⟩ | ⟨m, w, j, -, -, rfl, -⟩
      · rfl
      · exact writeOf_withRm _ _
    · exact emitFold_writes xr rest _ i hi

/-- `emitHead` drops at most a leading load (`emitHead_cases` without the cache size). -/
theorem emitHead_rest (c : Cache) (items : List Item) :
    (emitHead c items).2 = items ∨
      ∃ w m tl, items = .ld w false .rax m :: tl ∧ (emitHead c items).2 = tl := by
  unfold emitHead
  dsimp only
  split
  · repeat' split
    all_goals first | exact .inl rfl | exact .inr ⟨_, _, _, rfl, rfl⟩
  · exact .inl rfl

/-- (c) `emit` keeps each frame (`rbp`) write of the sequence (the converse of `emit_writes` for
frame writes): the head `emit` may drop is a load. -/
theorem emit_keeps_frame_writes {c : Cache} {cand : List Item} :
    ∀ it ∈ cand, ∀ m n, writeOf it = some (m, n) → m.base = .rbp →
      ∃ e ∈ (c.emit cand).1, writeOf e = some (m, n) := by
  intro it hit m n hw hb
  obtain ⟨mb, md⟩ := m
  simp only at hb
  subst hb
  rw [emit_eq]
  dsimp only
  have hrest : it ∈ (emitHead { c with tick := c.tick + 1 } cand).2 := by
    rcases emitHead_rest { c with tick := c.tick + 1 } cand with h | ⟨w, m', tl, rfl, h⟩
    · rw [h]; exact hit
    · rw [h]
      rcases List.mem_cons.1 hit with rfl | h'
      · simp [writeOf] at hw
      · exact h'
  obtain ⟨e, he, hwe⟩ := emitFold_writes _ _ _ it hrest
  refine ⟨e, he, ?_⟩
  rw [hwe, writeOf_ren, hw]
  all_goals first | rfl | simp [R]

/-- A `writeOf` write off `rbp` is the item's `frameWrite`. -/
theorem frameWrite_of_writeOf {it : Item} {m : M} {n : Nat} (hw : writeOf it = some (m, n))
    (hb : m.base = .rbp) : Asm.frameWrite it = some (m, n) := by
  cases it <;> simp only [writeOf, reduceCtorEq, Option.some.injEq, Prod.mk.injEq] at hw <;>
    obtain ⟨rfl, rfl⟩ := hw <;> simp [Asm.frameWrite, hb, Ryo.Vm.Asm.bytes]

set_option hygiene false in
/-- Take `sequence … = some (items, br)` apart into the concrete item lists (as `seq_items`). -/
macro "seq_unfold" : tactic =>
  `(tactic| (
    all_goals simp only [sequence, bind, Option.bind_eq_some_iff, pure] at h
    all_goals (repeat' (first
      | (obtain ⟨_, hs, h⟩ := h
         split at hs <;> (try simp only [Option.some.injEq, reduceCtorEq] at hs) <;> (try subst hs))
      | split at h))
    all_goals (try simp only [Option.some.injEq, Prod.mk.injEq] at h)
    all_goals (try obtain ⟨rfl, _⟩ := h)
    all_goals (try (repeat' split))))

set_option hygiene false in
/-- Take `sequence … = some (items, br)` apart with slot `i` known (`hk`), as `seq_items` (no
`cases` on widths: the `match w`/`if`s are split where they are). -/
macro "seq_open " hk:ident : tactic =>
  `(tactic| (
    simp only [sequence, $hk:ident, bind, Option.bind_eq_some_iff, pure, Option.some.injEq,
      exists_eq_left'] at h
    repeat' (first
      | (obtain ⟨_, hs, h⟩ := h
         split at hs <;> (try simp only [Option.some.injEq, reduceCtorEq] at hs) <;> (try subst hs))
      | split at h)
    all_goals (try simp only [Option.some.injEq, Prod.mk.injEq, reduceCtorEq] at h)
    all_goals (try obtain ⟨rfl, _⟩ := h)
    all_goals (try simp only [cmpImmSeq])
    all_goals (repeat' split)))

set_option hygiene false in
/-- `seq_covers_out`'s close when the destination store is the sequence's last item. -/
macro "cov_last" : tactic =>
  `(tactic| (
    all_goals (try (simp only [outSize] at h2; omega))
    all_goals (refine ⟨_, List.mem_of_getLast? rfl, _, _, rfl, rfl, h1, ?_⟩)
    all_goals (simp only [outSize, M.frame, Ryo.Vm.Asm.bytes, wbytes_eq, Ryo.X86.W.bits] at h2 ⊢)
    all_goals (first | omega | (cases ‹W› <;> simp [Ryo.Proofs.Inline.wbytes] at h2 ⊢ <;> omega))))

/-- (b) The destination range `[d, d + outSize cls)` is covered by the sequence's frame stores:
by the last item (a store of `outSize cls` bytes at `d`), the overflow classes' store before
the flag, `mov128`'s two halves. -/
theorem seq_covers_out {T : Type} {cls : Class} {ops : List (R.Opnd T)} {items : List Item}
    {br : Option Cond} (h : sequence cls ops = some (items, br)) {s : BitVec 32}
    (h0 : ops[0]? = some (.slot s)) {o : Int} (h1 : s.toInt ≤ o) (h2 : o < s.toInt + outSize cls) :
    ∃ it ∈ items, ∃ m n, writeOf it = some (m, n) ∧ m.base = .rbp ∧ m.disp.toInt ≤ o ∧
      o < m.disp.toInt + n := by
  cases cls
  case mov128 =>
    -- the two 8-byte halves: `[s + 8]` (third item) and `[s]` (last), `(s + 8).toInt = s.toInt + 8`
    -- from the guard
    seq_open h0
    all_goals
      have hg := ‹¬((_ || _) = true)›
      simp only [Bool.or_eq_true, decide_eq_true_eq, not_or, M.frame, Int.not_le,
        ge_iff_le] at hg
      have e8 : (s + 8).toInt = s.toInt + 8 := by
        have hb := toInt_bounds s
        rw [BitVec.toInt_add_of_not_saddOverflow]
        · rfl
        · simp [BitVec.saddOverflow]; omega
      simp only [outSize] at h2
      by_cases hlo8 : o < s.toInt + 8
      · exact ⟨_, List.mem_of_getLast? rfl, _, _, rfl, rfl, h1,
          by simp only [M.frame, Ryo.Vm.Asm.bytes, Ryo.X86.W.bits]; omega⟩
      · refine ⟨_, List.mem_cons_of_mem _ (List.mem_cons_of_mem _ (List.mem_cons_self ..)),
          _, _, rfl, rfl, ?_, ?_⟩ <;>
          simp only [M.frame, Ryo.Vm.Asm.bytes, Ryo.X86.W.bits] <;> omega
  case ovf =>
    -- `[ld, alu, st w d] ++ flagSeq …`: the third item
    seq_open h0
    all_goals refine ⟨_, List.mem_append_left _ (List.mem_cons_of_mem _ (List.mem_cons_of_mem _
      (List.mem_singleton_self _))), _, _, rfl, rfl, h1, ?_⟩
    all_goals (simp only [outSize, M.frame, Ryo.Vm.Asm.bytes, ← wbytes_eq] at h2 ⊢)
    all_goals (cases ‹W› <;> simp_all <;> omega)
  case mulOvf =>
    -- `body ++ [st w d] ++ flagSeq …`: the last item before the flag
    seq_open h0
    all_goals refine ⟨_, List.mem_append_left _ (List.mem_append_right _
      (List.mem_singleton_self _)), _, _, rfl, rfl, h1, ?_⟩
    all_goals (simp only [outSize, M.frame, Ryo.Vm.Asm.bytes, ← wbytes_eq] at h2 ⊢)
    all_goals omega
  all_goals (seq_open h0)
  all_goals cov_last

/-- (b) An overflow class's sequence ends with its flag store `mov [o], cl` (`flagSeq`). -/
theorem seq_covers_flag {T : Type} {cls : Class} {ops : List (R.Opnd T)} {items : List Item}
    {br : Option Cond} (h : sequence cls ops = some (items, br)) (hov : isOvf cls = true)
    {s : BitVec 32} (h1 : ops[1]? = some (.slot s)) :
    Item.st .b .rcx (M.frame s) ∈ items := by
  cases cls <;> simp only [isOvf, Bool.false_eq_true] at hov
  all_goals (seq_open h1)
  all_goals exact List.mem_of_getLast? rfl

/-- `emit`'s loop pushes, for each item, its renamed copy (`withRm` of it for a cached read). -/
theorem emitFold_mem (xr : Reg) : ∀ (rest : List Item) (st : Cache × Array Item),
    ∀ it ∈ rest, ∃ e ∈ (rest.foldl (emitStep xr) st).2.toList,
      e = ren xr it ∨ ∃ rm, e = withRm (ren xr it) rm
  | [], _, _, hi => nomatch hi
  | it :: rest, st, i, hi => by
    obtain ⟨e', c', heq, hcase⟩ := emitStep_cases xr st it
    simp only [List.foldl_cons, heq]
    rcases List.mem_cons.1 hi with rfl | hi
    · refine ⟨e', emitFold_mono xr rest _ e' (by simp [Array.toList_push]), ?_⟩
      rcases hcase with ⟨rfl, -⟩ | ⟨m, w, j, -, -, rfl, -⟩
      · exact .inl rfl
      · exact .inr ⟨_, rfl⟩
    · exact emitFold_mem xr rest _ i hi

/-- `emit` keeps the flag store `mov [rbp + s], cl` as it is (no `rax` in it; not a read). -/
theorem emit_keeps_flag {c : Cache} {cand : List Item} {s : BitVec 32}
    (hit : Item.st .b .rcx (M.frame s) ∈ cand) : Item.st .b .rcx (M.frame s) ∈ (c.emit cand).1 := by
  rw [emit_eq]
  dsimp only
  have hrest : Item.st .b .rcx (M.frame s) ∈ (emitHead { c with tick := c.tick + 1 } cand).2 := by
    rcases emitHead_rest { c with tick := c.tick + 1 } cand with h | ⟨w, m', tl, rfl, h⟩
    · rw [h]; exact hit
    · rw [h]
      rcases List.mem_cons.1 hit with h' | h'
      · cases h'
      · exact h'
  obtain ⟨e, he, hcase⟩ := emitFold_mem _ _ _ _ hrest
  have hren : ∀ xr, ren xr (Item.st .b .rcx (M.frame s)) = Item.st .b .rcx (M.frame s) := by
    intro xr; first | rfl | simp [ren, mapRegs, R, M.frame]
  rcases hcase with rfl | ⟨rm, rfl⟩
  · rw [hren] at he; exact he
  · rw [hren] at he; exact he

/-! ### `emit` as an item-by-item map, and the stores' kinds (DS-T9) -/

/-- `emit`'s output against its input: item by item, renamed (`ren`), or also with a cached read
(`withRm` of a pool register). -/
inductive EmitRel (xr : Reg) : List Item → List Item → Prop
  | nil : EmitRel xr [] []
  | cons {e it : Item} {es its : List Item} :
      (e = ren xr it ∨ ∃ i : Nat, e = withRm (ren xr it) (.reg pool[i]!)) → EmitRel xr es its →
      EmitRel xr (e :: es) (it :: its)

theorem emitFold_rel (xr : Reg) : ∀ (rest : List Item) (st : Cache × Array Item),
    ∃ es, (rest.foldl (emitStep xr) st).2.toList = st.2.toList ++ es ∧ EmitRel xr es rest
  | [], st => ⟨[], by simp, .nil⟩
  | it :: rest, st => by
    obtain ⟨e', c', heq, hcase⟩ := emitStep_cases xr st it
    obtain ⟨es, h1, h2⟩ := emitFold_rel xr rest (c'.update e', st.2.push e')
    refine ⟨e' :: es, ?_, .cons ?_ h2⟩
    · simp only [List.foldl_cons, heq, h1, Array.toList_push, List.append_assoc,
        List.singleton_append]
    · rcases hcase with ⟨rfl, -⟩ | ⟨m, w, i, -, -, rfl, -⟩
      · exact .inl rfl
      · exact .inr ⟨i, rfl⟩

/-- `emit` is `EmitRel` against its input, less a leading load it may take from the cache. -/
theorem emit_rel (c : Cache) (cand : List Item) :
    ∃ (xr : Reg) (rest : List Item), xr ≠ .rcx ∧
      (rest = cand ∨ ∃ w m, cand = .ld w false .rax m :: rest) ∧
      EmitRel xr (c.emit cand).1 rest := by
  rw [emit_eq]
  dsimp only
  obtain ⟨es, h1, h2⟩ := emitFold_rel (pool[(emitHead { c with tick := c.tick + 1 } cand).1]!)
    (emitHead { c with tick := c.tick + 1 } cand).2 _
  have hr : (emitHead { c with tick := c.tick + 1 } cand).2 = cand ∨
      ∃ w m, cand = .ld w false .rax m :: (emitHead { c with tick := c.tick + 1 } cand).2 := by
    rcases emitHead_rest { c with tick := c.tick + 1 } cand with h | ⟨w, m, tl, e, h⟩
    · exact .inl h
    · exact .inr ⟨w, m, by rw [h]; exact e⟩
  exact ⟨_, _, pool_ne_rcx (emitHead { c with tick := c.tick + 1 } cand).1, hr,
    by rw [h1]; exact h2⟩

/-- An item's kind: a store's (`some (src == rcx)`), and whether it may follow a store
(`st`, `setcc cl`). -/
def kd (it : Item) : Option Bool × Bool :=
  (match it with
    | .st _ r _ => some (r == .rcx)
    | _ => none,
   match it with
    | .st .. | .setccCl _ => true
    | _ => false)

theorem kd_emit {xr : Reg} (hxr : xr ≠ .rcx) {e it : Item}
    (h : e = ren xr it ∨ ∃ i : Nat, e = withRm (ren xr it) (.reg pool[i]!)) : kd e = kd it := by
  rcases h with rfl | ⟨i, rfl⟩ <;> cases it <;> try rfl
  all_goals
    rename_i r _
    simp only [ren, mapRegs, withRm, kd]
    by_cases hr : r = .rax
    · subst hr
      have : (xr == Reg.rcx) = false := beq_false_of_ne hxr
      simp [R, this]
    · simp [R, hr]

theorem EmitRel.map_kd {xr : Reg} (hxr : xr ≠ .rcx) {es its : List Item}
    (h : EmitRel xr es its) : es.map kd = its.map kd := by
  induction h with
  | nil => rfl
  | cons he _ ih => rw [List.map_cons, List.map_cons, kd_emit hxr he, ih]

/-- No store is followed by an item other than a store or `setcc cl`. -/
def tailK : List (Option Bool × Bool) → Bool
  | [] => true
  | p :: l => (p.1.isNone || l.all (·.2)) && tailK l

/-- At most one store of each kind (`src = rcx` or not). -/
def uniqK : List (Option Bool × Bool) → Bool
  | [] => true
  | p :: l => (match p.1 with
      | none => true
      | some b => l.all (fun q => q.1 != some b)) && uniqK l

theorem tailK_spec : ∀ (pre : List Item) {x : Item} {post : List Item},
    tailK ((pre ++ x :: post).map kd) = true → (kd x).1.isSome = true →
      ∀ y ∈ post, (kd y).2 = true
  | [], x, post, h, hx, y, hy => by
    simp only [List.nil_append, List.map_cons, tailK, Bool.and_eq_true, Bool.or_eq_true] at h
    rcases h.1 with h1 | h1
    · cases hk : (kd x).1 with
      | none => rw [hk] at hx; cases hx
      | some b => rw [hk] at h1; cases h1
    · exact List.all_eq_true.1 h1 (kd y) (List.mem_map.2 ⟨y, hy, rfl⟩)
  | a :: pre, x, post, h, hx, y, hy => by
    simp only [List.cons_append, List.map_cons, tailK, Bool.and_eq_true] at h
    exact tailK_spec pre h.2 hx y hy

theorem uniqK_spec : ∀ (l : List Item) (i j : Nat) {x : Item},
    uniqK (l.map kd) = true → l[i]? = some x → l[j]? = some x → (kd x).1.isSome = true → i = j
  | [], i, j, x, _, hi, _, _ => by simp at hi
  | a :: l, i, j, x, h, hi, hj, hx => by
    simp only [List.map_cons, uniqK, Bool.and_eq_true] at h
    obtain ⟨h1, h2⟩ := h
    have hfar : ∀ k : Nat, l[k]? = some a → (kd a).1.isSome = true → False := by
      intro k hk ha
      cases hka : (kd a).1 with
      | none => rw [hka] at ha; cases ha
      | some b =>
        rw [hka] at h1
        simp only at h1
        have := List.all_eq_true.1 h1 (kd a) (List.mem_map.2 ⟨a, List.mem_of_getElem? hk, rfl⟩)
        simp [hka] at this
    cases i with
    | zero =>
      cases j with
      | zero => rfl
      | succ j =>
        simp only [List.getElem?_cons_zero, Option.some.injEq] at hi
        subst hi
        simp only [List.getElem?_cons_succ] at hj
        exact (hfar j hj hx).elim
    | succ i =>
      cases j with
      | zero =>
        simp only [List.getElem?_cons_zero, Option.some.injEq] at hj
        subst hj
        simp only [List.getElem?_cons_succ] at hi
        exact (hfar i hi hx).elim
      | succ j =>
        simp only [List.getElem?_cons_succ] at hi hj
        exact congrArg (· + 1) (uniqK_spec l i j h2 hi hj hx)

set_option hygiene false in
/-- `seq_open` without a known slot. -/
macro "seq_open0" : tactic =>
  `(tactic| (
    simp only [sequence, bind, Option.bind_eq_some_iff, pure, Option.some.injEq,
      exists_eq_left'] at h
    repeat' (first
      | (obtain ⟨_, hs, h⟩ := h
         split at hs <;> (try simp only [Option.some.injEq, reduceCtorEq] at hs) <;> (try subst hs))
      | split at h)
    all_goals (try simp only [Option.some.injEq, Prod.mk.injEq, reduceCtorEq] at h)
    all_goals (try obtain ⟨rfl, _⟩ := h)
    all_goals (try simp only [cmpImmSeq])
    all_goals (repeat' split)))

/-- (DS-T9) Per class: a sequence's stores come last, or before `flagSeq`'s `setcc cl` and flag
store; and it has at most one store from `rcx` and one from another register. -/
theorem seq_kinds {T : Type} {cls : Class} {ops : List (R.Opnd T)} {cand : List Item}
    {br : Option Cond} (h : sequence cls ops = some (cand, br)) :
    tailK (cand.map kd) = true ∧ uniqK (cand.map kd) = true := by
  cases cls
  all_goals seq_open0
  all_goals exact ⟨rfl, rfl⟩

/-- `seq_kinds` for what `emit` outputs. -/
theorem emit_kinds {T : Type} {cls : Class} {ops : List (R.Opnd T)} {cand : List Item}
    {br : Option Cond} (h : sequence cls ops = some (cand, br)) (c : Cache) :
    tailK ((c.emit cand).1.map kd) = true ∧ uniqK ((c.emit cand).1.map kd) = true := by
  obtain ⟨ht, hu⟩ := seq_kinds h
  obtain ⟨xr, rest, hxr, hrest, hrel⟩ := emit_rel c cand
  rw [hrel.map_kd hxr]
  rcases hrest with rfl | ⟨w, m, rfl⟩
  · exact ⟨ht, hu⟩
  · simp only [List.map_cons, tailK, uniqK, Bool.and_eq_true] at ht hu
    exact ⟨ht.2, hu.2⟩

/-! ### Frame writers before a store (DS-T9, `dinline_pre_apart`) -/

/-- A possible frame writer (what `Asm.frameWrite` can be `some` on, whatever the base). -/
def pw (it : Item) : Bool :=
  match it with
  | .st .. | .stImm .. | .setcc .. => true
  | .aluImm _ _ (.mem _) _ => true
  | _ => false

/-- A store. -/
def isStB (it : Item) : Bool :=
  match it with
  | .st .. => true
  | _ => false

/-- No possible frame writer before a store. -/
def preB : List Item → Bool
  | [] => true
  | y :: l => (!pw y || !(l.any isStB)) && preB l

theorem pw_of_fw {it : Item} (h : (Asm.frameWrite it).isSome = true) : pw it = true := by
  cases it <;> (try cases ‹Rm›) <;> simp_all [Asm.frameWrite, pw]

theorem pw_emit {xr : Reg} {e it : Item}
    (h : e = ren xr it ∨ ∃ i : Nat, e = withRm (ren xr it) (.reg pool[i]!)) (hp : pw e = true) :
    pw it = true := by
  rcases h with rfl | ⟨i, rfl⟩ <;> cases it <;> (try cases ‹Rm›) <;>
    simp_all [pw, ren, mapRegs, mapRegs.mapRm, withRm]

theorem isStB_emit {xr : Reg} {e it : Item}
    (h : e = ren xr it ∨ ∃ i : Nat, e = withRm (ren xr it) (.reg pool[i]!)) :
    isStB e = isStB it := by
  rcases h with rfl | ⟨i, rfl⟩ <;> cases it <;> rfl

theorem EmitRel.any_isStB {xr : Reg} {es its : List Item} (h : EmitRel xr es its) :
    es.any isStB = its.any isStB := by
  induction h with
  | nil => rfl
  | cons he _ ih => rw [List.any_cons, List.any_cons, isStB_emit he, ih]

theorem EmitRel.preB_of {xr : Reg} {es its : List Item} (h : EmitRel xr es its)
    (hp : preB its = true) : preB es = true := by
  revert hp
  induction h with
  | nil => intro _; rfl
  | @cons e it es its he hr ih =>
    intro hp
    simp only [CacheStep.preB, Bool.and_eq_true, Bool.or_eq_true, Bool.not_eq_true'] at hp ⊢
    refine ⟨?_, ih hp.2⟩
    rw [hr.any_isStB]
    rcases hp.1 with h1 | h1
    · left
      cases hpe : pw e
      · rfl
      · rw [pw_emit he hpe] at h1; cases h1
    · exact .inr h1

theorem preB_spec : ∀ (pre : List Item) {x : Item} {post : List Item},
    preB (pre ++ x :: post) = true → isStB x = true → ∀ y ∈ pre, pw y = false
  | [], _, _, _, _, y, hy => by cases hy
  | a :: pre, x, post, h, hx, y, hy => by
    simp only [List.cons_append, CacheStep.preB, Bool.and_eq_true, Bool.or_eq_true,
      Bool.not_eq_true'] at h
    rcases List.mem_cons.1 hy with rfl | hy'
    · rcases h.1 with h1 | h1
      · exact h1
      · exfalso
        have : (pre ++ x :: post).any isStB = true := List.any_eq_true.2 ⟨x, by simp, hx⟩
        rw [this] at h1
        cases h1
    · exact preB_spec pre h.2 hx y hy'

/-- (DS-T9) Per class, but `mov128` and the overflow classes: no frame writer before a store. -/
theorem seq_preB {T : Type} {cls : Class} {ops : List (R.Opnd T)} {cand : List Item}
    {br : Option Cond} (h : sequence cls ops = some (cand, br))
    (hc : ¬ (cls = .mov128 ∨ isOvf cls = true)) : preB cand = true := by
  cases cls
  case mov128 => exact (hc (.inl rfl)).elim
  case ovf => exact (hc (.inr rfl)).elim
  case mulOvf => exact (hc (.inr rfl)).elim
  all_goals seq_open0
  all_goals rfl

/-- `seq_preB` for what `emit` outputs. -/
theorem emit_preB {T : Type} {cls : Class} {ops : List (R.Opnd T)} {cand : List Item}
    {br : Option Cond} (h : sequence cls ops = some (cand, br))
    (hc : ¬ (cls = .mov128 ∨ isOvf cls = true)) (c : Cache) : preB (c.emit cand).1 = true := by
  have hp := seq_preB h hc
  obtain ⟨xr, rest, -, hrest, hrel⟩ := emit_rel c cand
  refine hrel.preB_of ?_
  rcases hrest with rfl | ⟨w, m, rfl⟩
  · exact hp
  · simp only [CacheStep.preB, Bool.and_eq_true] at hp
    exact hp.2

end Ryo.Proofs.CacheStep

namespace Ryo.Proofs.DeadStore

open Ryo.Spec Ryo.Vm Ryo.Vm.R Ryo.X86 Ryo.Vm.Asm Ryo.Proofs.DecodeSound Ryo.Proofs.DecodeLink

variable {S : Setup} {code : ByteArray} {relocs : Array Reloc} {rodata : ByteArray}
  {callSites : Array CallSite} {dropped : Array DroppedStore} {scopes : Array R.Scope}
  {mode : Ryo.Obj.Mode}

/-- `reducedOf`'s dropped-store records: the protos'. -/
theorem reducedOf_dropForm {r : ReadResult} {pe : Bool} {d : Decoded}
    (h : reducedOf r pe = .ok d) :
    d.droppedItems = r.protos.map (·.droppedItem) ∧ d.consumed = r.protos.map (·.consumed) := by
  unfold reducedOf at h
  obtain ⟨insns, -, h2⟩ := ebind_ok h
  obtain ⟨head, -, h3⟩ := ebind_ok h2
  cases h3
  exact ⟨rfl, rfl⟩

/-- The decoder's dropped-store records at `k` are proto `k`'s. -/
theorem dropForm_at (hD : Decodes S code relocs rodata callSites dropped scopes mode) {k : Nat}
    (hk : k < S.r.protos.size) :
    S.c.d.droppedItems[k]? = some S.r.protos[k].droppedItem ∧
      S.c.d.consumed[k]? = some S.r.protos[k].consumed := by
  obtain ⟨h1, h2⟩ := reducedOf_dropForm hD.reduced
  exact ⟨by simp [h1, hk], by simp [h2, hk]⟩

/-- `inlineInsn_erased_dropped`, strengthened: the stores the read consumed are a prefix `pre` of
`dropped` (`dropped = pre ++ dr'`), `q.consumed` counts them, any makes `q.dropped` hold, and
the erased item (`q.droppedItem`, and the one `eraseIdx` drops) is one of theirs. A second copy
of the loop invariant, with `pre` in place of `dropped`. -/
theorem inlineInsn_consumed {cache cache' : Cache} {dropped dr' : List DroppedStore}
    {c c' : Cursor} {q : Proto}
    (h : (inlineInsn cache dropped true).run c = .ok (some (q, cache', dr'), c')) :
    ∃ cand br out pre, decodeInline cand br = some (q.op, q.ops) ∧ cache.emit cand = (out, cache') ∧
      dropped = pre ++ dr' ∧ q.consumed = pre.length ∧ (pre ≠ [] → q.dropped = true) ∧
      (∀ it, q.droppedItem = some it → ∃ d ∈ pre, it = d.item) ∧
      (q.items = out ∨ ∃ i, ∃ d ∈ pre, out[i]? = some d.item ∧ q.items = out.eraseIdx i) ∧
      (pre ≠ [] → ∃ i, ∃ d ∈ pre, out[i]? = some d.item ∧ q.items = out.eraseIdx i) := by
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
  let J : Option (Option (Proto × Cache × List DroppedStore)) × Array Item ×
      Option (Cond × Nat) × Bool × Nat × List DroppedStore × Bool → Cursor → Prop :=
    fun st _ => ∃ pre, dropped = pre ++ st.2.2.2.2.2.1 ∧ (pre ≠ [] → st.2.2.2.1 = true) ∧
      (st.2.2.2.1 = true → ∃ d ∈ pre, st.2.1.toList[st.2.2.2.2.1]? = some d.item)
  have key := forIn_range_inv (fun st cur => I st cur ∧ J st cur) (fun st cur => D st cur ∧ J st cur)
    _ ?step _ _ c c3 st ⟨⟨rfl, rfl, rfl, rfl, DecDrop.nil _ _⟩, [], (List.nil_append _).symm,
      fun hne => (hne rfl).elim, fun hw => (Bool.false_ne_true hw).elim⟩ h3
  case step =>
    intro a b cur r cur' hI hr
    obtain ⟨o, items, branch, wd, da, dr, ended⟩ := b
    obtain ⟨⟨ho, hend, hc, hbr, hd⟩, pre, hpre, hJ0, hJ1⟩ := hI
    simp only at ho hend hc hbr hd hr hpre hJ0 hJ1
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
          exact ⟨⟨rfl, rfl, by rw [e6], rfl, by simpa using hd'⟩, ⟨pre ++ [d], by rw [hpre]; simp, fun _ => rfl, fun _ => ⟨d, by simp, by simp [Array.toList_push]⟩⟩⟩
        · obtain ⟨rfl, rfl⟩ := pure_ok hr
          exact ⟨.inr ⟨rfl, rfl, .inl ⟨rfl, by simpa using hd'⟩⟩, ⟨pre ++ [d], by rw [hpre]; simp, fun _ => rfl, fun _ => ⟨d, by simp, by simp [Array.toList_push]⟩⟩⟩
      · obtain ⟨x, c5, h5, hr⟩ := bind_ok hr
        cases x with
        | none =>
          have := run_tryItem_none h5; subst this
          obtain ⟨u, c7, h7, hr⟩ := bind_ok hr
          rw [run_setPos] at h7; cases h7
          obtain ⟨rfl, rfl⟩ := pure_ok hr
          exact ⟨.inl rfl, pre, hpre, hJ0, hJ1⟩
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
              refine ⟨.inr ⟨rfl, rfl, .inl ⟨rfl, ?_⟩⟩, ⟨pre, hpre, hJ0, fun hw => (hJ1 hw).imp fun _ ⟨hd1, hx⟩ => ⟨hd1, push_keep hx⟩⟩⟩
              simp only [Array.toList_push]; exact hd.snoc_item hn
            · obtain ⟨rfl, rfl⟩ := pure_ok hr
              refine ⟨⟨rfl, rfl, by rw [e7], rfl, ?_⟩, ⟨pre, hpre, hJ0, fun hw => (hJ1 hw).imp fun _ ⟨hd1, hx⟩ => ⟨hd1, push_keep hx⟩⟩⟩
              simp only [Array.toList_push]; exact hd.snoc_item hn
          · split at hr
            · split at hr
              · obtain ⟨rfl, rfl⟩ := pure_ok hr
                exact ⟨.inr ⟨rfl, rfl, .inr ⟨_, _, _, rfl, hd.snoc_item hn⟩⟩, pre, hpre, hJ0, hJ1⟩
              · obtain ⟨u, c7, h7, hr⟩ := bind_ok hr
                rw [run_setPos] at h7; cases h7
                obtain ⟨rfl, rfl⟩ := pure_ok hr
                exact ⟨.inl rfl, pre, hpre, hJ0, hJ1⟩
            · obtain ⟨u, c7, h7, hr⟩ := bind_ok hr
              rw [run_setPos] at h7; cases h7
              obtain ⟨rfl, rfl⟩ := pure_ok hr
              exact ⟨.inl rfl, pre, hpre, hJ0, hJ1⟩
    · obtain ⟨x, c5, h5, hr⟩ := bind_ok hr
      cases x with
      | none =>
        have := run_tryItem_none h5; subst this
        obtain ⟨u, c7, h7, hr⟩ := bind_ok hr
        rw [run_setPos] at h7; cases h7
        obtain ⟨rfl, rfl⟩ := pure_ok hr
        exact ⟨.inl rfl, pre, hpre, hJ0, hJ1⟩
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
            refine ⟨.inr ⟨rfl, rfl, .inl ⟨rfl, ?_⟩⟩, ⟨pre, hpre, hJ0, fun hw => (hJ1 hw).imp fun _ ⟨hd1, hx⟩ => ⟨hd1, push_keep hx⟩⟩⟩
            simp only [Array.toList_push]; exact hd.snoc_item hn
          · obtain ⟨rfl, rfl⟩ := pure_ok hr
            refine ⟨⟨rfl, rfl, by rw [e7], rfl, ?_⟩, ⟨pre, hpre, hJ0, fun hw => (hJ1 hw).imp fun _ ⟨hd1, hx⟩ => ⟨hd1, push_keep hx⟩⟩⟩
            simp only [Array.toList_push]; exact hd.snoc_item hn
        · split at hr
          · split at hr
            · obtain ⟨rfl, rfl⟩ := pure_ok hr
              exact ⟨.inr ⟨rfl, rfl, .inr ⟨_, _, _, rfl, hd.snoc_item hn⟩⟩, pre, hpre, hJ0, hJ1⟩
            · obtain ⟨u, c7, h7, hr⟩ := bind_ok hr
              rw [run_setPos] at h7; cases h7
              obtain ⟨rfl, rfl⟩ := pure_ok hr
              exact ⟨.inl rfl, pre, hpre, hJ0, hJ1⟩
          · obtain ⟨u, c7, h7, hr⟩ := bind_ok hr
            rw [run_setPos] at h7; cases h7
            obtain ⟨rfl, rfl⟩ := pure_ok hr
            exact ⟨.inl rfl, pre, hpre, hJ0, hJ1⟩
  have hJ := key.elim And.right And.right
  replace key := key.imp And.left And.left
  obtain ⟨o, items, branch, wd, da, dr, ended⟩ := st
  dsimp only at key h hJ
  rcases key with ⟨rfl, rfl, -, -, -⟩ | rfl | ⟨rfl, rfl, hd⟩
  · obtain ⟨u, c4, -, h4⟩ := bind_ok h
    obtain ⟨he, -⟩ := pure_ok h4; cases he
  · obtain ⟨he, -⟩ := pure_ok h; cases he
  · simp only [Bool.not_true, Bool.false_eq_true, ↓reduceIte] at h
    -- the candidate the decoder accepted
    have found : ∃ cand d, decodeInline cand branch = some d ∧
        (cache.emit cand).1 = items.toList ∧ cache' = (cache.emit cand).2 ∧
        q.op = d.1 ∧ q.ops = d.2 ∧ q.pos = c.pos ∧ q.handler = none ∧ q.dropped = wd ∧
        q.items = (if wd = true then items.toList.eraseIdx da else items.toList) ∧
        q.cacheOut = some (cacheSlots (cache.emit cand).2) ∧
        q.droppedItem = (if wd = true then items.toList[da]? else none) ∧
        q.consumed = dropped.length - dr.length ∧ c' = c3 ∧ dr = dr' := by
      have fin : ∀ cand d (P : Proto) pp cc, decodeInline cand branch = some d →
          (if ((cache.emit cand).fst != items.toList) = true then none
            else some (P, (cache.emit cand).snd)) = some (pp, cc) →
          P.op = d.1 → P.ops = d.2 → P.pos = c.pos → P.handler = none → P.dropped = wd →
          P.items = (if wd = true then items.toList.eraseIdx da else items.toList) →
          P.cacheOut = some (cacheSlots (cache.emit cand).2) →
          P.droppedItem = (if wd = true then items.toList[da]? else none) →
          P.consumed = dropped.length - dr.length →
          (pp, cc, dr) = (q, cache', dr') → c' = c3 → ∃ cand d, decodeInline cand branch = some d ∧
            (cache.emit cand).1 = items.toList ∧ cache' = (cache.emit cand).2 ∧
            q.op = d.1 ∧ q.ops = d.2 ∧ q.pos = c.pos ∧ q.handler = none ∧ q.dropped = wd ∧
            q.items = (if wd = true then items.toList.eraseIdx da else items.toList) ∧
        q.cacheOut = some (cacheSlots (cache.emit cand).2) ∧
        q.droppedItem = (if wd = true then items.toList[da]? else none) ∧
        q.consumed = dropped.length - dr.length ∧ c' = c3 ∧ dr = dr' := by
        intro cand d P pp cc hd hh h1 h2 h3 h4 h5 h6 h7 h8 h9 he hc
        split at hh
        · cases hh
        · rename_i hne
          simp only [Option.some.injEq, Prod.mk.injEq] at hh he
          obtain ⟨rfl, rfl⟩ := hh
          obtain ⟨rfl, rfl, rfl⟩ := he
          exact ⟨cand, d, hd, by simpa using hne, rfl, h1, h2, h3, h4, h5, h6, h7, h8, h9, hc, rfl⟩
      split at h
      · rename_i d hdi
        split at h
        · rename_i pp cc hacc
          obtain ⟨he, rfl⟩ := pure_ok h
          exact fin _ d _ pp cc hdi hacc rfl rfl rfl rfl rfl rfl rfl rfl rfl (by cases he; rfl) rfl
        · obtain ⟨res, c4, h4, hk2⟩ := bind_ok h
          have key2 := forIn_list_inv (fun (st : Option (Option (Proto × Cache × List DroppedStore)) × Unit) cur => st.1 = none ∧ cur = c3)
            (fun (st : Option (Option (Proto × Cache × List DroppedStore)) × Unit) cur => cur = c3 ∧
                ∃ (cand : List Item) (d : Full.Opcode × List (Opnd Nat)) (P pp : Proto) (cc : Cache), decodeInline cand branch = some d ∧
              (if ((cache.emit cand).fst != items.toList) = true then none
                else some (P, (cache.emit cand).snd)) = some (pp, cc) ∧
              P.op = d.1 ∧ P.ops = d.2 ∧ P.pos = c.pos ∧ P.handler = none ∧ P.dropped = wd ∧
              P.items = (if wd = true then items.toList.eraseIdx da else items.toList) ∧
              P.cacheOut = some (cacheSlots (cache.emit cand).2) ∧
              P.droppedItem = (if wd = true then items.toList[da]? else none) ∧
              P.consumed = dropped.length - dr.length ∧
              st.1 = some (some (pp, cc, dr))) _ ?step2 _ _ c3 c4 res ⟨rfl, rfl⟩ h4
          case step2 =>
            intro cand st cur r cur' hI hr
            split at hr
            · rename_i d hd
              split at hr
              · rename_i pp cc hacc
                obtain ⟨rfl, rfl⟩ := pure_ok hr
                exact ⟨hI.2, cand, d, _, pp, cc, hd, hacc, rfl, rfl, rfl, rfl, rfl, rfl, rfl, rfl, rfl, rfl⟩
              · obtain ⟨rfl, rfl⟩ := pure_ok hr; exact ⟨rfl, hI.2⟩
            · obtain ⟨rfl, rfl⟩ := pure_ok hr; exact ⟨rfl, hI.2⟩
          rcases key2 with ⟨hn, rfl⟩ | ⟨rfl, cand, d, P, pp, cc, hd, hacc, h1, h2, h3, h4', h5, h6, h7, h8, h9, hs⟩
          · split at hk2
            · rename_i r hr; rw [hn] at hr; cases hr
            · obtain ⟨u, c5, -, hk3⟩ := bind_ok hk2
              obtain ⟨he, -⟩ := pure_ok hk3; cases he
          · split at hk2
            · rename_i r hr; rw [hs] at hr; cases hr
              obtain ⟨he, rfl⟩ := pure_ok hk2
              exact fin cand d P pp cc hd hacc h1 h2 h3 h4' h5 h6 h7 h8 h9 (by cases he; rfl) rfl
            · rename_i hr; rw [hs] at hr; cases hr
      · obtain ⟨res, c4, h4, hk2⟩ := bind_ok h
        have key2 := forIn_list_inv (fun (st : Option (Option (Proto × Cache × List DroppedStore)) × Unit) cur => st.1 = none ∧ cur = c3)
          (fun (st : Option (Option (Proto × Cache × List DroppedStore)) × Unit) cur => cur = c3 ∧
                ∃ (cand : List Item) (d : Full.Opcode × List (Opnd Nat)) (P pp : Proto) (cc : Cache), decodeInline cand branch = some d ∧
            (if ((cache.emit cand).fst != items.toList) = true then none
              else some (P, (cache.emit cand).snd)) = some (pp, cc) ∧
            P.op = d.1 ∧ P.ops = d.2 ∧ P.pos = c.pos ∧ P.handler = none ∧ P.dropped = wd ∧
            P.items = (if wd = true then items.toList.eraseIdx da else items.toList) ∧
            P.cacheOut = some (cacheSlots (cache.emit cand).2) ∧
              P.droppedItem = (if wd = true then items.toList[da]? else none) ∧
              P.consumed = dropped.length - dr.length ∧
            st.1 = some (some (pp, cc, dr))) _ ?step2 _ _ c3 c4 res ⟨rfl, rfl⟩ h4
        case step2 =>
          intro cand st cur r cur' hI hr
          split at hr
          · rename_i d hd
            split at hr
            · rename_i pp cc hacc
              obtain ⟨rfl, rfl⟩ := pure_ok hr
              exact ⟨hI.2, cand, d, _, pp, cc, hd, hacc, rfl, rfl, rfl, rfl, rfl, rfl, rfl, rfl, rfl, rfl⟩
            · obtain ⟨rfl, rfl⟩ := pure_ok hr; exact ⟨rfl, hI.2⟩
          · obtain ⟨rfl, rfl⟩ := pure_ok hr; exact ⟨rfl, hI.2⟩
        rcases key2 with ⟨hn, rfl⟩ | ⟨rfl, cand, d, P, pp, cc, hd, hacc, h1, h2, h3, h4', h5, h6, h7, h8, h9, hs⟩
        · split at hk2
          · rename_i r hr; rw [hn] at hr; cases hr
          · obtain ⟨u, c5, -, hk3⟩ := bind_ok hk2
            obtain ⟨he, -⟩ := pure_ok hk3; cases he
        · split at hk2
          · rename_i r hr; rw [hs] at hr; cases hr
            obtain ⟨he, rfl⟩ := pure_ok hk2
            exact fin cand d P pp cc hd hacc h1 h2 h3 h4' h5 h6 h7 h8 h9 (by cases he; rfl) rfl
          · rename_i hr; rw [hs] at hr; cases hr
    obtain ⟨cand, d, hdi, hemit, hcache, hop, hops, hpos, hh, hdr, hits, hco, hdit, hcons, rfl,
      rfl⟩ := found
    obtain ⟨pre, hpre, hJ0, hJ1⟩ := hJ
    refine ⟨cand, branch, items.toList, pre, by rw [hop, hops]; exact hdi,
      by rw [hcache, ← hemit], hpre, ?_, fun hne => hdr.trans (hJ0 hne), fun it hit => ?_, ?_,
      fun hne => ?_⟩
    · -- `exact` (not omega) so the prefix's tail matches `hcons`'s up to defeq
      rw [hcons]
      apply Nat.sub_eq_of_eq_add
      have e := congrArg List.length hpre
      simp only [List.length_append] at e
      exact e
    · rw [hdit] at hit
      split at hit
      · rename_i hw
        obtain ⟨d0, hd0, hx⟩ := hJ1 hw
        exact ⟨d0, hd0, Option.some.inj (hit.symm.trans hx)⟩
      · cases hit
    · rw [hits]
      split
      · rename_i hw
        obtain ⟨d0, hd0, hx⟩ := hJ1 hw
        exact .inr ⟨da, d0, hd0, hx, rfl⟩
      · exact Or.inl rfl
    · obtain ⟨d0, hd0, hx⟩ := hJ1 (hJ0 hne)
      exact ⟨da, d0, hd0, hx, by rw [hits, if_pos (hJ0 hne)]⟩

/-- `inlineInsn_consumed` at `k`, with `S.dr k = ds ++ dr'`: the consumed stores are `ds`. -/
theorem dropForm_consumed {k : Nat} {cache cache' : Cache} {q : Proto} {c c' : Cursor}
    {dr' ds : List DroppedStore}
    (hr : (inlineInsn cache (S.dr k) true).run c = .ok (some (q, cache', dr'), c'))
    (hds : S.dr k = ds ++ dr') :
    ∃ cand br out, decodeInline cand br = some (q.op, q.ops) ∧ cache.emit cand = (out, cache') ∧
      q.consumed = ds.length ∧ (ds ≠ [] → q.dropped = true) ∧
      (∀ it, q.droppedItem = some it → ∃ d ∈ ds, it = d.item) ∧
      (q.items = out ∨ ∃ i, ∃ d ∈ ds, out[i]? = some d.item ∧ q.items = out.eraseIdx i) := by
  obtain ⟨cand, br, out, pre, h1, h2, hpre, h3, h4, h5, h6, -⟩ := inlineInsn_consumed hr
  have e0 : pre ++ dr' = ds ++ dr' := hpre.symm.trans hds
  have e : pre = ds := by
    first
      | exact List.append_cancel_right e0
      | simpa using e0
  subst e
  exact ⟨cand, br, out, h1, h2, h3, h4, h5, h6⟩

/-- `reducedOf`'s `dropped`: the protos with a dropped store. -/
theorem dropForm_reducedOf_dropped {r : ReadResult} {pe : Bool} {d : Decoded}
    (h : reducedOf r pe = .ok d) :
    d.dropped = ((List.range r.protos.size).filter (r.protos[·]!.dropped)).toArray := by
  unfold reducedOf at h
  obtain ⟨insns, -, h2⟩ := ebind_ok h
  obtain ⟨head, -, h3⟩ := ebind_ok h2
  cases h3
  rfl

/-- An instruction whose proto has a dropped store is in `d.dropped`. -/
theorem dropForm_mem_dropped (hD : Decodes S code relocs rodata callSites dropped scopes mode)
    {k p : Nat} {q : Proto} {c' : Cursor} {cache' : Cache} (hP : ProtoFacts S k p q c' cache')
    (h : q.dropped = true) : k ∈ S.c.d.dropped.toList := by
  obtain ⟨_, p1, ctr, _, _, hlt, hpk⟩ := protoFacts_insnOf hP
  rw [dropForm_reducedOf_dropped hD.reduced]
  have h' : S.r.protos[k]!.dropped = true := by
    rw [getElem!_pos S.r.protos k hlt, hpk]; exact h
  simp only [List.toList_toArray, List.mem_filter, List.mem_range]
  exact ⟨hlt, h'⟩

/-- **The decoder fact (to check, see the module comment).** Each dropped store instruction `k`'s
sequence consumed writes exactly `Frame.droppedStore`'s range of `k`. -/
def DroppedAgree (S : Setup) (k : Nat) (ds : List DroppedStore) : Prop :=
  ∀ d ∈ ds, ∃ s n, Frame.droppedStore S.c.d k = some (s, n) ∧
    Asm.frameWrite d.item = some (X86.M.frame s, n)

/-- `DroppedAgree` from the checker: for a dropped instruction `k` (`Cert.hform`, `droppedFormOk`),
the read consumed one store (`consumed = 1`), whose item (`droppedItem`) is a store of
`droppedStore`'s range. -/
theorem dropForm_agree (hD : Decodes S code relocs rodata callSites dropped scopes mode)
    (C : Cert S) {k p : Nat} {cache : Cache} {q : Proto} {c c' : Cursor} {cache' : Cache}
    {dr' : List DroppedStore} (hP : ProtoFacts S k p q c' cache')
    (hr : (inlineInsn cache (S.dr k) true).run c = .ok (some (q, cache', dr'), c'))
    {ds : List DroppedStore} (hds : S.dr k = ds ++ dr') (hk : k ∈ S.c.d.dropped.toList) :
    DroppedAgree S k ds := by
  obtain ⟨_, _, _, _, _, hcons, -, hit, -⟩ := dropForm_consumed hr hds
  obtain ⟨_, p1, ctr, _, _, hlt, hpk⟩ := protoFacts_insnOf hP
  obtain ⟨hdi0, hco0⟩ := dropForm_at hD hlt
  have hdi : S.c.d.droppedItems[k]? = some q.droppedItem := by rw [hdi0, hpk]
  have hco : S.c.d.consumed[k]? = some q.consumed := by rw [hco0, hpk]
  have hf := C.hform k hk
  unfold Frame.droppedFormOk at hf
  obtain ⟨hc1, hm⟩ := Eq.mp (Bool.and_eq_true _ _) (Eq.mp (Bool.and_eq_true _ _) hf).1
  obtain ⟨hlt2, heq2⟩ := Array.getElem?_eq_some_iff.1 hco
  have hc : S.c.d.consumed[k]! = q.consumed := by
    rw [getElem!_pos S.c.d.consumed k hlt2]; exact heq2
  rw [hc, beq_iff_eq] at hc1
  have hlen : ds.length = 1 := hcons.symm.trans hc1
  obtain ⟨d0, rfl⟩ : ∃ d0, ds = [d0] := by
    rcases ds with _ | ⟨d0, _ | ⟨d1, tl⟩⟩
    · simp at hlen
    · exact ⟨d0, rfl⟩
    · simp only [List.length_cons] at hlen; omega
  intro d hd
  rw [List.mem_singleton] at hd
  subst hd
  split at hm
  · rename_i it s n h1 h2
    have hq : q.droppedItem = some it := Option.some.inj (hdi.symm.trans h1)
    obtain ⟨d1, hd1, rfl⟩ := hit it hq
    rw [List.mem_singleton] at hd1
    subst hd1
    exact ⟨s, n, h2, by simpa using hm⟩
  · exact absurd hm Bool.false_ne_true


/-- Sim.lean's `dinline_dropW`. With `DroppedAgree` (`dropForm_agree`), `DropW ds o` puts `o` in
`droppedStore`'s range (`droppedBitsAt`), which is in the frame (`droppedInFrame_bounds`,
`Cert.hframe`); `k ∈ dropped` from `q.dropped` (`ds ≠ []`, `dropForm_consumed`). Privacy after
the step: the objects after `k`'s scopes are in `esc[k]` (`escIn_post`), the operation keeps
`escaped` (`hkeep`), and `droppedPrivate` keeps the range out of `esc[k]`'s bytes. The step is
given as its scopes `hsc` and `hkeep` (Sim.lean's `dinline_step` and `opSem_out`). -/
theorem dropForm_dropW (hD : Decodes S code relocs rodata callSites dropped scopes mode)
    (C : Cert S) {k p : Nat} {cache : Cache} {q : Proto} {c' : Cursor}
    {cache' : Cache} {dr' : List DroppedStore} (hP : ProtoFacts S k p q c' cache')
    (hr : (inlineInsn cache (S.dr k) true).run (atPos S.body p) =
      .ok (some (q, cache', dr'), c'))
    {s s1 s' : R.RState} (hs : s.pc = k)
    (hsc : (S.c.scopesAt s.pc).foldlM R.applyScope s = .ok s1)
    (hkeep : s'.st.escaped = s1.st.escaped)
    (hesc : EscSound S C s) {ds : List DroppedStore} (hds : S.dr k = ds ++ dr') :
    ∀ o, DropW ds o → k ∈ S.c.d.dropped.toList ∧ InFrame S o ∧
      (Frame.droppedBitsAt S.c.d k).testBit (bit S o) = true ∧ s'.st.escapedAt o = none := by
  intro o ⟨d, hd, hw⟩
  obtain ⟨_, _, _, _, _, -, hne, -, -⟩ := dropForm_consumed hr hds
  have hk := dropForm_mem_dropped hD hP (hne (List.ne_nil_of_mem hd))
  obtain ⟨sl, n, hst, hfw⟩ := dropForm_agree hD C hP hr hds hk d hd
  obtain ⟨m, n', hfw', hlo, hhi⟩ := hw
  rw [hfw] at hfw'
  obtain ⟨rfl, rfl⟩ := Prod.mk.inj (Option.some.inj hfw')
  change sl.toInt ≤ o at hlo
  change o < sl.toInt + (n : Int) at hhi
  obtain ⟨hb1, hb2⟩ := droppedInFrame_bounds (C.hframe k hk) hst
  have hIF : InFrame S o := ⟨by omega, by omega⟩
  have hdb : (Frame.droppedBitsAt S.c.d k).testBit (bit S o) = true := by
    refine testBit_droppedBitsAt hst ?_ ?_ <;> simp only [Frame.range, bit] <;> omega
  refine ⟨hk, hIF, hdb, ?_⟩
  have hE : EscIn S.c.d C.fl.esc[k]! s1.st := by
    rw [← hs]; exact escIn_post (at_ := C.fl.esc) hesc hsc
  cases he : s'.st.escapedAt o with
  | none => rfl
  | some e =>
    exfalso
    obtain ⟨hem, h1, h2⟩ := Ryo.Proofs.Inline.escapedAt_some he
    rw [hkeep] at hem
    obtain ⟨j, k', sc, a, hb, hj, -, hoff, hsz⟩ := hE e hem
    have hbit : (Frame.escBytesOf S.c.d C.fl.esc[k]!).testBit (bit S o) = true :=
      testBit_escBytesOf hb hj (by simp only [Frame.range, bit]; omega)
        (by simp only [Frame.range, bit]; omega)
    have hp := C.hpriv k hk
    unfold Frame.droppedPrivate at hp
    simp only [hst] at hp
    have hB : (Frame.bitsOf (Frame.range S.c.d.frameSize sl n).1
        (Frame.range S.c.d.frameSize sl n).2).testBit (bit S o) = true := by
      unfold Frame.droppedBitsAt at hdb
      simp only [hst] at hdb
      exact hdb
    have hz := beq_iff_eq.1 hp
    have h0 := Nat.testBit_and (Frame.escBytesOf S.c.d C.fl.esc[k]!)
      (Frame.bitsOf (Frame.range S.c.d.frameSize sl n).1 (Frame.range S.c.d.frameSize sl n).2)
      (bit S o)
    rw [hz, Nat.zero_testBit, hbit, hB] at h0
    exact absurd h0 (by decide)

/-- A dropped instruction consumed one store (`droppedFormOk`). -/
theorem dropForm_consumed_one (hD : Decodes S code relocs rodata callSites dropped scopes mode)
    (C : Cert S) {k p : Nat} {q : Proto} {c' : Cursor} {cache' : Cache}
    (hP : ProtoFacts S k p q c' cache') (hk : k ∈ S.c.d.dropped.toList) : q.consumed = 1 := by
  obtain ⟨p1, counter, hpk⟩ := hP.proto
  have hpk' : S.r.protos[k]'hP.lt = { q with pos := p1, counter } := by
    rw [Array.getElem?_eq_getElem hP.lt] at hpk; exact Option.some.inj hpk
  obtain ⟨-, hco0⟩ := dropForm_at hD hP.lt
  rw [hpk'] at hco0
  have hf := C.hform k hk
  unfold Frame.droppedFormOk at hf
  have hc1 := (Eq.mp (Bool.and_eq_true _ _) (Eq.mp (Bool.and_eq_true _ _) hf).1).1
  obtain ⟨hlt2, heq2⟩ := Array.getElem?_eq_some_iff.1 hco0
  have hc : S.c.d.consumed[k]! = q.consumed := by
    rw [getElem!_pos S.c.d.consumed k hlt2]; exact heq2
  rw [hc, beq_iff_eq] at hc1
  exact hc1

/-- `e ∈ l` is `l[i]`'s value or stays in `l.eraseIdx i`. -/
theorem mem_eraseIdx_or {α : Type} {l : List α} {i : Nat} {e x : α} (he : e ∈ l)
    (hx : l[i]? = some x) : e = x ∨ e ∈ l.eraseIdx i := by
  obtain ⟨j, hj⟩ := List.mem_iff_getElem?.1 he
  by_cases hji : j = i
  · subst hji; exact .inl (Option.some.inj (hj.symm.trans hx))
  · exact .inr (List.mem_eraseIdx_iff_getElem?.2 ⟨j, hji, hj⟩)

/-- A frame write of an emitted item is kept, or is the erased (dropped) store's. -/
theorem writes_out {out items : List Item} {ds : List DroppedStore}
    (hitems : items = out ∨ ∃ i, ∃ d ∈ ds, out[i]? = some d.item ∧ items = out.eraseIdx i)
    {e : Item} (he : e ∈ out) {m : M} {n : Nat} {o : Int} (hf : Asm.frameWrite e = some (m, n))
    (h1 : m.disp.toInt ≤ o) (h2 : o < m.disp.toInt + n) : KeptW items o ∨ DropW ds o := by
  have hW : Writes e o := ⟨m, n, hf, h1, h2⟩
  rcases hitems with rfl | ⟨i, d, hd, hx, rfl⟩
  · exact .inl ⟨e, he, hW⟩
  · rcases mem_eraseIdx_or he hx with rfl | h
    · exact .inr ⟨d, hd, hW⟩
    · exact .inl ⟨e, h, hW⟩

/-- An emitted item is kept, or is the erased (dropped) store's item. -/
theorem mem_out_cases {out items : List Item} {ds : List DroppedStore}
    (hitems : items = out ∨ ∃ i, ∃ d ∈ ds, out[i]? = some d.item ∧ items = out.eraseIdx i)
    {e : Item} (he : e ∈ out) : e ∈ items ∨ ∃ d ∈ ds, e = d.item := by
  rcases hitems with rfl | ⟨i, d, hd, hx, rfl⟩
  · exact .inl he
  · rcases mem_eraseIdx_or he hx with h | h
    · exact .inr ⟨d, hd, h⟩
    · exact .inl h

/-- Sim.lean's `dinline_opSem_frame`. The R operation writes the frame only in its write ranges
(`opSem_frame_or`), which are `(d, outSize cls)` and an overflow op's `(o, 1)`
(`wranges_cases`); each of their bytes is written by a store of the sequence
(`seq_covers_out`, `seq_covers_flag`), which `emit` keeps (`emit_keeps_frame_writes`), and which
is kept or a consumed dropped store (`dropForm_consumed`). -/
theorem dropForm_opSem_frame (hD : Decodes S code relocs rodata callSites dropped scopes mode)
    (H : Hyps S) {k p : Nat} {cache : Cache} {q : Proto} {c' : Cursor} {cache' : Cache}
    {dr' : List DroppedStore} (hP : ProtoFacts S k p q c' cache')
    (hr : (inlineInsn cache (S.dr k) true).run (atPos S.body p) =
      .ok (some (q, cache', dr'), c'))
    {op : Reduced.Opcode} {ops : List (Opnd Nat)} (hi : S.c.d.insns[k]? = some (.native op ops))
    {s1 : R.RState} {vals : OpSem.Operands} {ctl : OpSem.Control} {st' : OpSem.State}
    (hv : Ryo.Proofs.Inline.nativeVals S.c.ρ q.op ops = some vals)
    (hop : OpSem.opSem q.op vals s1.st {} = .ok (ctl, st')) {ds : List DroppedStore}
    (hds : S.dr k = ds ++ dr') :
    ∀ o, InFrame S o → ¬ KeptW q.items o → ¬ DropW ds o → st'.frame o = s1.st.frame o := by
  intro o _ hnk hnd
  rcases Ryo.Proofs.MemPost.opSem_frame_or hop o with h | ⟨r, hr', hin⟩
  · exact h
  exfalso
  obtain ⟨cand, br, out, hdi, hemit, -, -, -, hitems⟩ := dropForm_consumed hr hds
  obtain ⟨cls, hmem, hseq⟩ := decodeInline_spec hdi
  have hshape := (H.inlineOk _ _ hmem).shape
  -- the R operands against the decoded ones
  obtain ⟨i, hi', hio⟩ := hP.insn
  obtain ⟨p1, counter, hpk⟩ := hP.proto
  have hpk' : S.r.protos[k]'hP.lt = { q with pos := p1, counter } := by
    rw [Array.getElem?_eq_getElem hP.lt] at hpk; exact Option.some.inj hpk
  have hio' := hio hP.lt
  rw [hpk'] at hio'
  unfold InsnOf at hio'
  have hh := (inlineInsn_read_drop hr).2.1
  simp only [hh] at hio'
  obtain ⟨op', ops', -, hi2, hmap⟩ := hio'
  have hii : i = .native op ops := Option.some.inj (hi'.symm.trans hi)
  subst hii
  cases hi2
  have hmap' : ops.map (opndMap (posOf S.r)) = q.ops := hmap
  have hkeep : ∀ it ∈ cand, ∀ m n, Ryo.Proofs.CacheStep.writeOf it = some (m, n) →
      m.base = .rbp → m.disp.toInt ≤ o → o < m.disp.toInt + n → False := by
    intro it hit m n hw hb hm1 hm2
    obtain ⟨e, he, hwe⟩ := Ryo.Proofs.CacheStep.emit_keeps_frame_writes (c := cache) it hit m n hw hb
    rw [hemit] at he
    rcases writes_out hitems he (Ryo.Proofs.CacheStep.frameWrite_of_writeOf hwe hb) hm1 hm2 with
      h | h
    · exact hnk h
    · exact hnd h
  simp only [Ryo.Vm.OpSem.inRange, decide_eq_true_eq] at hin
  rcases Ryo.Proofs.CacheStep.wranges_cases hshape hv hr' with ⟨s, h0, rfl⟩ | ⟨hov, s, h1, rfl⟩
  · have h0' : q.ops[0]? = some (.slot s) := by rw [← hmap', List.getElem?_map, h0]; rfl
    obtain ⟨it, hit, m, n, hw, hb, hm1, hm2⟩ :=
      Ryo.Proofs.CacheStep.seq_covers_out hseq h0' hin.1 hin.2
    exact hkeep it hit m n hw hb hm1 hm2
  · have h1' : q.ops[1]? = some (.slot s) := by rw [← hmap', List.getElem?_map, h1]; rfl
    have hit := Ryo.Proofs.CacheStep.seq_covers_flag hseq hov h1'
    have hl : s.toInt ≤ o := hin.1
    have hu : o < s.toInt + ((1 : Nat) : Int) := hin.2
    exact hkeep _ hit (M.frame s) 1 rfl rfl (by simp only [M.frame]; omega)
      (by simp only [M.frame]; omega)

set_option maxRecDepth 100000 in
theorem reduced_operandsTable : (List.range Reduced.ofFullTable.size).all (fun i =>
    (Reduced.ofFullTable[i]!).all fun op =>
      op.info.operands == (Full.Opcode.info ⟨i.toUInt16⟩).operands) = true := by
  -- DS-T9: true by `#eval`; `decide +kernel` doesn't finish (operand names are `String`s).
  sorry

/-- A reduced opcode has its full opcode's operands. -/
theorem ofFull_operands {f : Full.Opcode} {op : Reduced.Opcode}
    (h : Reduced.Opcode.ofFull f = some op) : op.info.operands = f.info.operands := by
  unfold Reduced.Opcode.ofFull at h
  have hlt : f.val.toNat < Reduced.ofFullTable.size := by
    refine Classical.byContradiction fun hn => ?_
    rw [getElem!_neg Reduced.ofFullTable f.val.toNat hn] at h
    cases h
  have := List.all_eq_true.1 reduced_operandsTable f.val.toNat (List.mem_range.2 hlt)
  rw [h] at this
  simp only [Option.all_some, beq_iff_eq] at this
  have hf : (⟨f.val.toNat.toUInt16⟩ : Full.Opcode) = f := by cases f; simp
  rw [hf] at this
  exact this

/-- An operand found by name in `l.zip ops` is in `l`, with that name. -/
theorem find_zip_name {α : Type} {l : List OperandInfo} {ops : List α} {x : OperandInfo} {v : α}
    {nm : String} (h : (l.zip ops).find? (·.1.name == nm) = some (x, v)) :
    x ∈ l ∧ x.name = nm := by
  have h1 := List.mem_of_find?_eq_some h
  have h2 := List.find?_some h
  exact ⟨(List.of_mem_zip h1).1, by simpa using h2⟩

/-- Sim.lean's `dinline_flag`. An overflow op's flag byte (`flagSlot`, its `"o"` operand) is
written by the sequence's flag store (`seq_covers_flag`), which `emit` keeps; it is not the
dropped store (`droppedFormOk_flagApart`: apart from the flag byte, or not a store from `rcx`). -/
theorem dropForm_flag (hD : Decodes S code relocs rodata callSites dropped scopes mode)
    (H : Hyps S) (C : Cert S) {k p : Nat} {cache : Cache} {q : Proto} {c' : Cursor}
    {cache' : Cache} {dr' : List DroppedStore} (hP : ProtoFacts S k p q c' cache')
    (hr : (inlineInsn cache (S.dr k) true).run (atPos S.body p) =
      .ok (some (q, cache', dr'), c')) :
    ∀ o, InFrame S o → (Frame.flagBits S.c.d k).testBit (bit S o) = true → KeptW q.items o := by
  intro o hIF hb
  obtain ⟨hF1, hF2⟩ := hIF
  -- the flag slot `fo`, and `o` is its byte
  unfold Frame.flagBits at hb
  cases hfs : Frame.flagSlot S.c.d k with
  | none => simp [hfs] at hb
  | some fo =>
  have hfs0 := hfs
  simp only [hfs, testBit_bitsOf, Bool.and_eq_true, decide_eq_true_eq] at hb
  simp only [Frame.range, bit] at hb
  have hlo : fo.toInt ≤ o := by omega
  have hhi : o < fo.toInt + 1 := by omega
  -- the instruction and its class
  obtain ⟨cand, br, out, pre, hdi, hemit, hpre, hcons, hne, hdit, hitems, -⟩ := inlineInsn_consumed hr
  obtain ⟨cls, hmem, hseq⟩ := decodeInline_spec hdi
  obtain ⟨⟨r0, -⟩, hocls⟩ := Ryo.Proofs.Inline.shapeOk_spec (H.inlineOk _ _ hmem).shape
  obtain ⟨i, hi', hio⟩ := hP.insn
  obtain ⟨p1, counter, hpk⟩ := hP.proto
  have hpk' : S.r.protos[k]'hP.lt = { q with pos := p1, counter } := by
    rw [Array.getElem?_eq_getElem hP.lt] at hpk; exact Option.some.inj hpk
  have hio' := hio hP.lt
  rw [hpk'] at hio'
  unfold InsnOf at hio'
  have hh := (inlineInsn_read_drop hr).2.1
  simp only [hh] at hio'
  obtain ⟨op, ops, hof, rfl, hmap⟩ := hio'
  have hmap' : ops.map (opndMap (posOf S.r)) = q.ops := hmap
  have hopnds : op.info.operands = Ryo.Proofs.Inline.classOperands cls := (ofFull_operands hof).trans hocls
  unfold Frame.flagSlot at hfs
  rw [hi'] at hfs
  simp only at hfs
  rw [hopnds] at hfs
  split at hfs
  · rename_i x v hfind
    -- `fo` is the `"o"` operand: an overflow class, `ops[1]`
    obtain ⟨hx, hxn⟩ := find_zip_name hfind
    have hovA : ∀ y ∈ Ryo.Proofs.Inline.classOperands cls, y.name = "o" → Ryo.Proofs.CacheStep.isOvf cls = true := by
      cases cls <;> simp [Ryo.Proofs.Inline.classOperands, Ryo.Proofs.CacheStep.isOvf]
    have hov := hovA x hx hxn
    have hoc : Ryo.Proofs.Inline.classOperands cls = ⟨"d", .slot⟩ :: ⟨"o", .slot⟩ :: [⟨"a", .slot⟩, ⟨"b", .slot⟩] := by
      cases cls <;> simp only [Ryo.Proofs.CacheStep.isOvf, Bool.false_eq_true] at hov <;> rfl
    rw [hoc] at hfind
    have hv : fo = v := (Option.some.inj hfs).symm
    subst hv
    have h1 : ops[1]? = some (.slot fo) := by
      rcases ops with _ | ⟨a0, _ | ⟨a1, rest⟩⟩ <;> simp [List.zip, List.find?] at hfind
      obtain ⟨-, rfl⟩ := hfind
      rfl
    have h1' : q.ops[1]? = some (.slot fo) := by rw [← hmap', List.getElem?_map, h1]; rfl
    -- the flag store `mov [o], cl`, kept by `emit`
    have hit := Ryo.Proofs.CacheStep.seq_covers_flag hseq hov h1'
    have he := Ryo.Proofs.CacheStep.emit_keeps_flag (c := cache) hit
    rw [hemit] at he
    have hfe : Asm.frameWrite (Item.st .b .rcx (X86.M.frame fo)) = some (X86.M.frame fo, 1) := by
      simp [Asm.frameWrite, X86.M.frame, Ryo.X86.W.bits]
    rcases mem_out_cases hitems he with h | ⟨d, hd, hde⟩
    · exact ⟨_, h, _, _, hfe, by simp only [X86.M.frame]; omega, by simp only [X86.M.frame]; omega⟩
    · -- the flag store is never a dropped one
      exfalso
      have hk := dropForm_mem_dropped hD hP (hne (List.ne_nil_of_mem hd))
      obtain ⟨sl, n, hst, hfw⟩ := dropForm_agree hD C hP hr hpre hk d hd
      rw [← hde, hfe] at hfw
      simp only [Option.some.injEq, Prod.mk.injEq, X86.M.frame, X86.M.mk.injEq, true_and] at hfw
      obtain ⟨rfl, rfl⟩ := hfw
      rcases droppedFormOk_flagApart (C.hform k hk) hst hfs0 with hap | ⟨w', src, m, hdk, hsrc⟩
      · omega
      · -- the dropped item is a store from `src ≠ rcx`, but it is the flag store
        obtain ⟨hdi0, hco0⟩ := dropForm_at hD hP.lt
        rw [hpk'] at hdi0 hco0
        have hq : q.droppedItem = some (.st w' src m) :=
          Option.some.inj (hdi0.symm.trans hdk)
        obtain ⟨d1, hd1, hx⟩ := hdit _ hq
        -- one consumed store (`droppedFormOk`): `d = d1`
        have hf := C.hform k hk
        unfold Frame.droppedFormOk at hf
        have hc1 := (Eq.mp (Bool.and_eq_true _ _) (Eq.mp (Bool.and_eq_true _ _) hf).1).1
        obtain ⟨hlt2, heq2⟩ := Array.getElem?_eq_some_iff.1 hco0
        have hc : S.c.d.consumed[k]! = q.consumed := by
          rw [getElem!_pos S.c.d.consumed k hlt2]; exact heq2
        rw [hc, beq_iff_eq] at hc1
        have hlen : pre.length = 1 := hcons.symm.trans hc1
        obtain ⟨d0, rfl⟩ : ∃ d0, pre = [d0] := by
          rcases pre with _ | ⟨d0, _ | ⟨d2, tl⟩⟩
          · simp at hlen
          · exact ⟨d0, rfl⟩
          · simp only [List.length_cons] at hlen; omega
        rw [List.mem_singleton] at hd hd1
        subst hd hd1
        rw [← hx] at hde
        cases hde
        exact hsrc rfl
  · cases hfs

end Ryo.Proofs.DeadStore
