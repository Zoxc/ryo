/-
Ryo.Proofs.DecodeLink.Read — what the decoder's functions read (aot.md §C2, toward M3
`decode_sound`): for each instruction kind, a successful run from a cursor reads a list of
items one after the other (`Dec`, `Ryo.Proofs.DecodeLink.Bytes`) that is the shape lemma's
item list, with the operands it records.

- `handlerArgs_ok`: the argument setup of a handler call is `Handler.setupItems` of the
  arguments `handlerArgs` returns (`setupItems_snoc`: one more argument, one more item).
- `thenSeq_read` (`ThenRead`): after the call, nothing (`op`, `lpad`), `test al, al; jz/jnz t`
  (`br`, the `then` being `branch (cond == z) t`), `table (n + 1)` (`switch`), `ud2` (`trap`).
- `islandCall_read`: `Island.islandPre`.
- `retSeq_read`: `retLoads k s`, the epilogue, `ret`; `k` a `u32`.
- `table_read`: `Switch.switchItems tb`, then (after the `int3` padding, not items) one entry
  per 4 bytes from `tb`, each what `Cursor.tableEntry` reads there.
- `insn_read` (`InsnRead`): `insn`'s result is one of a handler call (setup items, `call h`,
  then `thenSeq`), `ret`, `unreachable`, `jmp`, `island`.
- `argInsn_read`: `argInsn`'s `arg d, word a` is the stores `argStore a d pe`, re-read from the
  start (the first parse only moves the cursor: `PosOnly`, the `posonly` tactic).
-/
import Ryo.Proofs.DecodeLink.Run
import Ryo.Proofs.Island
import Ryo.Proofs.Switch

set_option linter.constructorNameAsVariable false
set_option linter.unusedSimpArgs false

namespace Ryo.Proofs.DecodeLink

open Ryo.X86 Ryo.Vm Ryo.Vm.R Ryo.Vm.Asm

/-! ### Handler calls -/

theorem argRef_addrArg {to : Ref} {a : Arg} (h : addrArg to = some a) : Handler.argRef a = some to := by
  cases to <;> simp only [addrArg] at h <;> first | (cases h; rfl) | cases h

theorem setupItems_snoc {mode : Ryo.Obj.Mode} {args : List Arg} {L : List Item} {a : Arg}
    {it : Item} (hs : Handler.setupItems mode args = some L)
    (hlt : args.length < handlerPositions mode.pe)
    (ha : Handler.posItem mode args.length a = some it) :
    Handler.setupItems mode (args ++ [a]) = some (L ++ [it]) := by
  unfold Handler.setupItems at hs ⊢
  have hc1 : args.length ≤ handlerPositions mode.pe := by omega
  have hc2 : (args ++ [a]).length ≤ handlerPositions mode.pe := by
    simp only [List.length_append, List.length_cons, List.length_nil]; omega
  simp only [hc1, ↓reduceIte] at hs
  simp only [hc2, ↓reduceIte]
  rw [List.zipIdx_append, List.mapM_append, hs]
  simp [ha]

/-- What `setupArg` reads is the item `posItem` puts the argument in its position with. -/
theorem setupArg_posItem {fr : Frame} {i : Nat} {it : Item} {a : Arg}
    (h : setupArg fr i it = some a) : Handler.posItem fr.mode i a = some it := by
  unfold setupArg at h
  unfold Handler.posItem
  split at h
  · rename_i hr
    rw [hr]
    split at h
    · rename_i m imm
      split at h
      · rename_i hm
        cases h
        simp only [beq_iff_eq] at hm
        subst hm
        have hlt : (imm.setWidth 64).toNat < 2 ^ 32 := by
          have := imm.isLt; simp only [BitVec.toNat_setWidth]; omega
        simp only [Handler.stackItem, hlt, ↓reduceIte, Option.some.injEq]
        simp
      · cases h
    · cases h
  · rename_i r hr
    rw [hr]
    split at h
    · rename_i hfp
      cases h
      simp only [beq_iff_eq] at hfp
      simp [Handler.argItem, hfp, Frame.fp]
    · split at h
      · split at h
        · rename_i hg; cases h; simp only [beq_iff_eq] at hg; subst hg; rfl
        · cases h
      · split at h
        · rename_i hg; cases h; simp only [beq_iff_eq] at hg; subst hg; rfl
        · cases h
      · split at h
        · rename_i g to hg
          simp only [beq_iff_eq] at hg
          subst hg
          have := argRef_addrArg h
          cases a <;> simp_all [Handler.argItem, Handler.argRef]
        · cases h
      · cases h

/-- `handlerArgs` reads each setup item as an argument for its position, in order: the
arguments' `setupItems` are the items, and the cursor stays. -/
theorem handlerArgs_ok {setup : List (Nat × Item)} {fr : Frame} {p0 : Nat} {c c' : Cursor}
    {args : List Arg} (h : (handlerArgs setup fr p0).run c = .ok (args, c')) :
    Handler.setupItems fr.mode args = some (setup.map (·.2)) ∧ c' = c := by
  unfold handlerArgs at h
  obtain ⟨st, c1, h1, h2⟩ := bind_ok h
  obtain ⟨rfl, rfl⟩ := pure_ok h2
  let I : List (Nat × Item) → Array Arg → Cursor → Prop := fun pre st c2 =>
    Handler.setupItems fr.mode st.toList = some (pre.map (·.2)) ∧ c2 = c
  have key := forIn_list_pre I (fun _ _ => False) _ ?step setup [] #[] c c1 st
    ⟨by simp [Handler.setupItems], rfl⟩ h1
  case step =>
    intro pre x out c2 r c3 hI hr
    obtain ⟨hs, rfl⟩ := hI
    obtain ⟨at_, it⟩ := x
    simp only at hr
    split at hr
    · obtain ⟨_, _, h4, -⟩ := bind_ok hr; exact (err_ok h4).elim
    rename_i hlt
    split at hr
    · rename_i a ha
      obtain ⟨rfl, rfl⟩ := pure_ok hr
      refine ⟨?_, rfl⟩
      simp only [Array.toList_push, List.map_append, List.map_cons, List.map_nil]
      have hl : out.toList.length < handlerPositions fr.mode.pe := by simp at hlt ⊢; omega
      have hp : Handler.posItem fr.mode out.toList.length a = some it := by
        simpa using setupArg_posItem ha
      exact setupItems_snoc hs hl hp
    · obtain ⟨_, _, h3, -⟩ := bind_ok hr; exact (err_ok h3).elim
  rcases key with ⟨hs, rfl⟩ | hf
  · exact ⟨by simpa using hs, rfl⟩
  · exact hf.elim

/-- `fixed want` (in `thenSeq`): the item is `want`. -/
theorem fixed_dec {c c' : Cursor} {want : Item} {u : Unit}
    (h : (do
      let at_ ← DM.pos
      let x ← DM.item
      if (x != want) = true then DM.err at_ "not the instruction's canonical sequence" else pure () : DM Unit).run c = .ok (u, c')) :
    Dec c c.pos [want] c'.pos ∧ c' = atPos c c'.pos := by
  obtain ⟨at_, c1, h1, h⟩ := bind_ok h
  obtain ⟨rfl, hc1⟩ := pos_run' h1
  subst c1
  obtain ⟨x, c2, h2, h⟩ := bind_ok h
  split at h
  · exact (err_ok h).elim
  · rename_i hx
    obtain ⟨-, rfl⟩ := pure_ok h
    simp only [bne_iff_ne, ne_eq, Decidable.not_not] at hx
    subst hx
    exact item_dec h2

/-- What `thenSeq` read after a handler call: nothing (`op`, `lpad`), `test al, al; jz/jnz t`
(`br`), the jump table (`switch`, `table`), `ud2` (`trap`). -/
inductive ThenRead (op : Full.Opcode) (nn : Nat) (c : Cursor) : Then Nat → Cursor → Prop
  | next : op.info.shape = .op ∨ op.info.shape = .lpad → ThenRead op nn c .next c
  | br {cond : Cond} {tgt : BitVec 32} {long : Bool} {c' : Cursor} : op.info.shape = .br →
      cond = .z ∨ cond = .nz → Dec c c.pos [.testAl, .branch cond tgt long] c'.pos →
      c' = atPos c c'.pos → ThenRead op nn c (.branch (cond == .z) tgt.toNat) c'
  | switch {ts : List Nat} {c' : Cursor} : op.info.shape = .switch →
      (table (nn + 1)).run c = .ok (ts, c') → ThenRead op nn c (.table ts) c'
  | trap {c' : Cursor} : op.info.shape = .trap → Dec c c.pos [.ud2] c'.pos →
      c' = atPos c c'.pos → ThenRead op nn c .trap c'

theorem thenSeq_read {op : Full.Opcode} {nn hat : Nat} {c c' : Cursor} {t : Then Nat}
    {sites : List (Nat × Nat)} (h : (thenSeq op nn hat).run c = .ok ((t, sites), c')) :
    ThenRead op nn c t c' := by
  unfold thenSeq at h
  split at h
  · rename_i hs; obtain ⟨he, rfl⟩ := pure_ok h; cases he; exact .next (.inl hs)
  · rename_i hs; obtain ⟨he, rfl⟩ := pure_ok h; cases he; exact .next (.inr hs)
  · rename_i hs
    obtain ⟨u, c1, h1, h⟩ := bind_ok h
    obtain ⟨d1, e1⟩ := fixed_dec h1
    obtain ⟨at_, c2, h2, h⟩ := bind_ok h
    obtain ⟨rfl, hc2⟩ := pos_run' h2
    subst c2
    obtain ⟨x, c3, h3, h⟩ := bind_ok h
    obtain ⟨d3, e3⟩ := item_dec h3
    split at h
    · rename_i cond tgt long
      split at h
      · rename_i hc
        obtain ⟨he, rfl⟩ := pure_ok h
        cases he
        refine .br (long := long) hs ?_ ?_ ?_
        · simp only [Bool.or_eq_true, beq_iff_eq] at hc; exact hc
        · rw [e1] at d3; exact d1.trans' d3
        · rw [e3, e1]
      · exact (err_ok h).elim
    · exact (err_ok h).elim
  · rename_i hs
    obtain ⟨ts, c1, h1, h⟩ := bind_ok h
    obtain ⟨he, rfl⟩ := pure_ok h
    cases he
    exact .switch hs h1
  · rename_i hs
    obtain ⟨u, c1, h1, h⟩ := bind_ok h
    obtain ⟨d1, e1⟩ := fixed_dec h1
    obtain ⟨he, rfl⟩ := pure_ok h
    cases he
    exact .trap hs d1 e1
  · exact (err_ok h).elim

/-! ### Islands, `ret`, jump tables -/

theorem islandCall_read {fr : Frame} {c c' : Cursor} {isl ops : Nat} {site : Nat × Nat}
    (h : (islandCall fr).run c = .ok ((isl, ops, site), c')) :
    Dec c c.pos (Island.islandPre fr.mode isl ops) c'.pos ∧
      c' = atPos c c'.pos := by
  unfold islandCall at h
  cases hpe : fr.mode.pe <;> rw [hpe] at h <;>
    simp (config := { zeta := false }) only [Bool.false_eq_true, ↓reduceIte] at h
  all_goals
    obtain ⟨at_, c1, h1, h⟩ := bind_ok h
    obtain ⟨rfl, hc1⟩ := pos_run' h1
    subst c1
    obtain ⟨c1, d1, e1, h⟩ := check_dec (fun _ _ _ hh => err_ok hh) h
    obtain ⟨x, c2, h2, h⟩ := bind_ok h
    obtain ⟨d2, e2⟩ := item_dec h2
    split at h
    case h_2 => exact (err_ok h).elim
    rename_i r o
    split at h
    · obtain ⟨_, _, h3, -⟩ := bind_ok h; exact (err_ok h3).elim
    rename_i hr
    simp only [bne_iff_ne, ne_eq, Decidable.not_not] at hr
    subst hr
    obtain ⟨st, c3, h3, h⟩ := bind_ok h
    obtain ⟨rfl, hc3⟩ := pos_run' h3
    subst c3
    obtain ⟨y, c4, h4, h⟩ := bind_ok h
    obtain ⟨d4, e4⟩ := item_dec h4
    split at h
    case h_2 => exact (err_ok h).elim
    rename_i isl'
    obtain ⟨he, rfl⟩ := pure_ok h
    cases he
    refine ⟨?_, by rw [e4, e2, e1]⟩
    simp only [Island.islandPre, Island.islandRegs, hpe, Bool.false_eq_true, ↓reduceIte,
      Frame.fp] at d1 ⊢
    rw [e1] at d2; rw [e2, e1] at d4
    have := (d1.trans' d2).trans' d4
    simpa using this

/-- `ret`'s sequence as `retSeq` reads it: `retLoads k s`, the epilogue, `ret`; `k` a `u32`. -/
theorem retSeq_read {fr : Frame} {c c' : Cursor} {s : BitVec 32} {k : Nat}
    (h : (retSeq fr).run c = .ok ((s, k), c')) :
    Dec c c.pos (retLoads k s ++ (fr.epilogue ++ [.ret])) c'.pos ∧ c' = atPos c c'.pos ∧
      k < 2 ^ 32 := by
  unfold retSeq at h
  obtain ⟨at_, c1, h1, h⟩ := bind_ok h
  obtain ⟨rfl, hc1⟩ := pos_run' h1
  subst c1
  obtain ⟨items, c2, h2, h⟩ := bind_ok h
  obtain ⟨d2, e2, -⟩ := take_dec h2
  split at h
  case h_2 => exact (err_ok h).elim
  rename_i s' parts _
  dsimp only at h
  split at h
  · obtain ⟨_, _, h3, -⟩ := bind_ok h; exact (err_ok h3).elim
  rename_i hk
  have hitems : retLoads (retKind parts) s' = items := by
    simp only [Bool.or_eq_true, bne_iff_ne, ne_eq, Bool.and_eq_true, not_or] at hk
    exact Decidable.not_not.mp hk.1
  obtain ⟨u, c3, h3, h⟩ := bind_ok h
  obtain ⟨he, rfl⟩ := pure_ok h
  cases he
  let I : List Item → PUnit → Cursor → Prop := fun pre _ cur =>
    Dec c c.pos (items ++ pre) cur.pos ∧ cur = atPos c cur.pos
  have key := forIn_list_pre I (fun _ _ => False) _ ?step (fr.epilogue ++ [.ret]) [] PUnit.unit c2 c3 u
    ⟨by simpa using d2, e2⟩ h3
  case step =>
    intro pre want b cur r cur' hI hr
    obtain ⟨hd, hc⟩ := hI
    obtain ⟨a, c4, h4, hr⟩ := bind_ok hr
    obtain ⟨rfl, hc4⟩ := pos_run' h4
    subst c4
    obtain ⟨x, c5, h5, hr2⟩ := bind_ok hr
    obtain ⟨d5, e5⟩ := item_dec h5
    by_cases hx : (x != want) = true
    · simp only [hx, ↓reduceIte] at hr2
      obtain ⟨_, _, h6, -⟩ := bind_ok hr2; exact (err_ok h6).elim
    · simp only [hx, Bool.false_eq_true, ↓reduceIte] at hr2
      have : x = want := by simpa using hx
      subst this
      obtain ⟨rfl, rfl⟩ := pure_ok hr2
      refine ⟨?_, by rw [e5, hc]⟩
      rw [hc] at d5
      rw [← List.append_assoc]
      exact hd.trans' d5
  rcases key with ⟨hd, hc⟩ | hf
  · refine ⟨?_, hc, ?_⟩
    · rw [hitems]; simpa using hd
    · simp only [retKind]; split <;> simp [u32] <;> omega
  · exact hf.elim

theorem tablePadding_pos {c c' : Cursor} {u : Unit} (h : DM.tablePadding.run c = .ok (u, c')) :
    c' = atPos c c'.pos := by
  unfold DM.tablePadding at h
  obtain ⟨st, c1, h1, h⟩ := bind_ok h
  have e : c' = c1 := by
    dsimp only at h
    split at h <;> exact (pure_ok h).2.symm
  subst e
  have key := forIn_range_inv (fun _ cur => cur = atPos c cur.pos) (fun _ cur => cur = atPos c cur.pos)
    _ ?step 4 (none, ()) c c' st rfl h1
  case step =>
    intro a b cur r cur' hI hr
    obtain ⟨x, c2, h2, hr2⟩ := bind_ok hr
    obtain ⟨hx2, hc2⟩ := get_run h2
    subst x; subst c2
    dsimp only at hr2
    split at hr2
    · obtain ⟨rfl, rfl⟩ := pure_ok hr2; exact hI
    · split at hr2
      · obtain ⟨_, _, h3, -⟩ := bind_ok hr2; exact (err_ok h3).elim
      · obtain ⟨_, c3, h3, hr3⟩ := bind_ok hr2
        rw [run_setPos] at h3; cases h3
        obtain ⟨rfl, rfl⟩ := pure_ok hr3
        obtain ⟨p, rfl⟩ : ∃ p, cur = atPos c p := ⟨_, hI⟩
        rfl
  rcases key with h | h <;> exact h

/-- The jump table `table n` reads: `switchItems tb`, then (after the padding) entries at `tb`,
4 bytes each, their targets `ts`. -/
theorem table_read {n : Nat} {c c' : Cursor} {ts : List Nat}
    (h : (table n).run c = .ok (ts, c')) :
    ∃ tb pE, ∃ es : List (BitVec 32), Dec c c.pos (Switch.switchItems tb) pE ∧ ts = es.map (·.toNat) ∧
      (∀ i (hi : i < es.length), (atPos c (tb.toNat + 4 * i)).tableEntry tb = some es[i]) ∧
      c' = atPos c (tb.toNat + 4 * es.length) := by
  unfold table at h
  obtain ⟨at_, c1, h1, h⟩ := bind_ok h
  obtain ⟨rfl, hc1⟩ := pos_run' h1
  subst c1
  obtain ⟨x, c2, h2, h⟩ := bind_ok h
  obtain ⟨d2, e2⟩ := item_dec h2
  split at h
  case h_2 => exact (err_ok h).elim
  rename_i tb
  obtain ⟨c3, d3, e3, h⟩ := check_dec (fun _ _ _ hh => err_ok hh) h
  obtain ⟨c4, d4, e4, h⟩ := check_dec (fun _ _ _ hh => err_ok hh) h
  obtain ⟨c5, d5, e5, h⟩ := check_dec (fun _ _ _ hh => err_ok hh) h
  obtain ⟨u, c6, h6, h⟩ := bind_ok h
  have e6 := tablePadding_pos h6
  obtain ⟨p, c7, h7, h⟩ := bind_ok h
  obtain ⟨rfl, hc7⟩ := pos_run' h7
  subst c7
  split at h
  · obtain ⟨_, _, h8, -⟩ := bind_ok h; exact (err_ok h8).elim
  rename_i hp
  have hp' : c6.pos = tb.toNat := by simpa using hp
  dsimp only at h
  obtain ⟨out, c8, h8, h⟩ := bind_ok h
  obtain ⟨rfl, rfl⟩ := pure_ok h
  let I : Array Nat → Cursor → Prop := fun out cur =>
    cur = atPos c (tb.toNat + 4 * out.size) ∧ ∀ i (hi : i < out.size),
      ∃ e, (atPos c (tb.toNat + 4 * i)).tableEntry tb = some e ∧ out[i] = e.toNat
  have key := forIn_range_inv I I _ ?step _ #[] c6 c8 out ?init h8
  case init =>
    refine ⟨?_, fun i hi => absurd hi (by simp)⟩
    rw [e6, e5, e4, e3, e2]; simp [hp']
  case step =>
    intro a b cur r cur' hI hr
    obtain ⟨hc, hb⟩ := hI
    obtain ⟨e, c9, h9, hr2⟩ := bind_ok hr
    obtain ⟨rfl, rfl⟩ := pure_ok hr2
    unfold DM.tableEntry at h9
    obtain ⟨y, c10, h10, h92⟩ := bind_ok h9
    obtain ⟨rfl, rfl⟩ := get_run h10
    split at h92
    · rename_i t ht
      obtain ⟨_, c11, h11, h93⟩ := bind_ok h92
      rw [run_setPos] at h11; cases h11
      obtain ⟨rfl, rfl⟩ := pure_ok h93
      simp only [BitVec.ofNat_toNat, BitVec.setWidth_eq] at ht
      refine ⟨?_, fun i hi => ?_⟩
      · rw [hc]; simp; omega
      · simp only [Array.size_push] at hi
        rcases Nat.lt_or_ge i b.size with hi' | hi'
        · rw [Array.getElem_push_lt hi']; exact hb i hi'
        · have : i = b.size := by omega
          subst this
          rw [Array.getElem_push_eq]
          rw [hc] at ht
          exact ⟨t, by simpa using ht, rfl⟩
    · exact (err_ok h92).elim
  rcases key with ⟨hc, hb⟩ | ⟨hc, hb⟩ <;>
  · refine ⟨tb, c5.pos, out.toList.map (BitVec.ofNat 32), ?_, ?_, ?_, ?_⟩
    · simp only [Switch.switchItems]
      rw [e2] at d3; rw [e3, e2] at d4; rw [e4, e3, e2] at d5
      have := ((d2.trans' d3).trans' d4).trans' d5
      simpa using this
    · apply List.ext_getElem (by simp)
      intro i h1 h2
      obtain ⟨e, -, he⟩ := hb i (by simpa using h1)
      simp [he]
    · intro i hi
      obtain ⟨e, he, he'⟩ := hb i (by simpa using hi)
      simp only [List.getElem_map, Array.getElem_toList, he', BitVec.ofNat_toNat, BitVec.setWidth_eq]
      exact he
    · simpa using hc

/-! ### `insn` -/

/-- An item that `insn` collects into the argument setup (on PE also the stack argument). -/
def isSetup (pe : Bool) : Item → Bool
  | .setReg .. | .lea .. | .mov .. | .leaM .. => true
  | it => pe && it.isStackArg

theorem Dec.nil_eq {c : Cursor} {p q : Nat} (h : Dec c p [] q) : q = p := by
  cases h; rfl

/-- What `insn` read (`insn_read`): a handler call (its setup items `setupItems` of its
arguments, read from the start, then `call h`, then what `thenSeq` reads), or `ret`
(`retSeq`), `unreachable` (`ud2`), `jmp` (a `jmp` within the function), `island`
(`islandCall`, and the operand array in the rodata), or in the pad region `resume`
(`add rsp, 40; ret`). -/
inductive InsnRead (fr : Frame) (ro : ByteArray) (c : Cursor) : Proto → Cursor → Prop
  | handler {items : List Item} {hat n len nn : Nat} {op : Full.Opcode} {args : List Arg}
      {t : Then Nat} {sites : List (Nat × Nat)} {c' : Cursor} :
      Dec c c.pos items hat → decodeItem (atPos c hat) = some (.call (.handler n), len) →
      Full.Opcode.ofNat? n = some op → op.hasHandler = true →
      Handler.setupItems fr.mode args = some items →
      (thenSeq op nn hat).run (atPos c (hat + len)) = .ok ((t, sites), c') →
      InsnRead fr ro c { op, handler := some (args, t), pos := c.pos, sites } c'
  | ret {s : BitVec 32} {k : Nat} {c' : Cursor} :
      (retSeq fr).run c = .ok ((s, k), c') →
      InsnRead fr ro c { op := .ret, ops := [.slot s, .imm (BitVec.ofNat 64 k)], pos := c.pos } c'
  | unreachable {len : Nat} :
      decodeItem c = some (.ud2, len) →
      InsnRead fr ro c { op := .unreachable, pos := c.pos } (atPos c (c.pos + len))
  | jmp {t : BitVec 32} {long : Bool} {len : Nat} :
      decodeItem c = some (.branch .always t long, len) →
      InsnRead fr ro c { op := .jmp, ops := [.target t.toNat], pos := c.pos } (atPos c (c.pos + len))
  | island {isl opsRo : Nat} {site : Nat × Nat} {ws : List (BitVec 32)} {c' : Cursor} :
      (islandCall fr).run c = .ok ((isl, opsRo, site), c') → opsArray ro opsRo = some ws →
      InsnRead fr ro c { op := .island, ops := [.sym isl, .words ws], pos := c.pos, sites := [site], bare := fr.mode.pe } c'
  /-- The pad region's `resume`: `add rsp, 40; ret` (its arguments are `read`'s, `resumeSlots`). -/
  | resume {len len2 : Nat} : fr.region = true →
      decodeItem c = some (.addRsp (BitVec.ofNat 32 peRegionAlloc), len) →
      decodeItem (atPos c (c.pos + len)) = some (.ret, len2) →
      InsnRead fr ro c { op := .resume, handler := some ([], .trap), pos := c.pos }
        (atPos c (c.pos + len + len2))
  /-- A dense switch's index computation and its table (`denseSwitch`), its handler call in the
  reduced form: not described further yet. -/
  | dense {c' : Cursor} {q : Proto} : (denseSwitch fr).run c = .ok (some q, c') → InsnRead fr ro c q c'

theorem insnCore_read {fr : Frame} {ro : ByteArray} {c c' : Cursor} {q : Proto}
    (h : (insnCore fr ro).run c = .ok (q, c')) : InsnRead fr ro c q c' := by
  have hc : c = atPos c c.pos := rfl
  unfold insnCore at h
  obtain ⟨p0, c1, h1, h⟩ := bind_ok h
  obtain ⟨rfl, hc1⟩ := pos_run' h1
  subst c1
  obtain ⟨fu, c2, h2, h⟩ := bind_ok h
  have := fuel_run h2; subst c2
  obtain ⟨st, c3, h3, h⟩ := bind_ok h
  let I : Array (Nat × Item) × Option (Nat × Item) → Cursor → Prop := fun st c3 =>
    st.2 = none ∧ Dec c c.pos (st.1.toList.map (·.2)) c3.pos ∧ c3 = atPos c c3.pos
  let D : Array (Nat × Item) × Option (Nat × Item) → Cursor → Prop := fun st c3 =>
    ∃ hat hd n, st.2 = some (hat, hd) ∧ Dec c c.pos (st.1.toList.map (·.2)) hat ∧
        decodeItem (atPos c hat) = some (hd, n) ∧ c3 = atPos c (hat + n) ∧
        isSetup fr.mode.pe hd = false
  have key := forIn_range_inv I D _ ?step fu (#[], none) c c3 st ⟨rfl, .nil _, hc⟩ h3
  case step =>
    intro a b c4 r c5 hI hr
    obtain ⟨hb2, hd, hc4⟩ := hI
    obtain ⟨p4, rfl⟩ : ∃ p, c4 = atPos c p := ⟨_, hc4⟩
    obtain ⟨at_, c6, h6, hr⟩ := bind_ok hr
    obtain ⟨rfl, hc6⟩ := pos_run' h6
    subst c6
    obtain ⟨it, c7, h7, hr⟩ := bind_ok hr
    obtain ⟨n, hn, rfl⟩ := run_item h7
    by_cases hsa : (fr.mode.pe && it.isStackArg) = true
    all_goals cases it <;> (try simp only [hsa, ↓reduceIte, Bool.false_eq_true] at hr) <;>
      obtain ⟨rfl, rfl⟩ := pure_ok hr
    all_goals first
      | (refine ⟨hb2, ?_, rfl⟩
         simp only [Array.toList_push, List.map_append, List.map_cons, List.map_nil]
         exact hd.append (Dec.single hn))
      | (refine ⟨_, _, n, rfl, hd, hn, rfl, ?_⟩
         first
           | (simp only [isSetup, Item.isStackArg, Bool.and_false]; done)
           | (simp only [isSetup]; simpa using hsa))
  rcases key with ⟨hnone, -, -⟩ | ⟨hat, hd, n, hst, hdec, hdh, rfl, hns⟩
  · simp only [hnone] at h
    exact (err_ok h).elim
  · obtain ⟨s1, s2⟩ := st
    simp only at hst
    subst hst
    dsimp only at h
    simp only [List.map_map] at hdec
    split at h
    · rename_i op hop
      obtain ⟨nh, rfl, hfl⟩ : ∃ nh, hd = .call (.handler nh) ∧
          (Full.Opcode.ofNat? nh).filter (·.hasHandler) = some op := by
        split at hop
        · exact ⟨_, rfl, hop⟩
        · cases hop
      have hfl' := Option.filter_eq_some_iff.mp hfl
      obtain ⟨args, c4, h4, h⟩ := bind_ok h
      obtain ⟨hset, rfl⟩ := handlerArgs_ok h4
      have mk : ∀ nn t sites c', (thenSeq op nn hat).run (atPos c (hat + n)) = .ok ((t, sites), c') →
          InsnRead fr ro c { op, handler := some (args, t), pos := c.pos, sites } c' :=
        fun nn t sites c' ht => .handler (by simpa using hdec) hdh hfl'.1 (by simpa using hfl'.2) hset ht
      split at h
      · rename_i l hl
        split at h
        · obtain ⟨nn, c5, h5, h⟩ := bind_ok h
          obtain ⟨rfl, rfl⟩ := pure_ok h5
          obtain ⟨x, c6, h6, h⟩ := bind_ok h
          obtain ⟨rfl, rfl⟩ := pure_ok h
          exact mk _ _ _ _ h6
        · split at h
          · split at h
            · obtain ⟨nn, c5, h5, h⟩ := bind_ok h
              obtain ⟨rfl, rfl⟩ := pure_ok h5
              obtain ⟨x, c6, h6, h⟩ := bind_ok h
              obtain ⟨rfl, rfl⟩ := pure_ok h
              exact mk _ _ _ _ h6
            · obtain ⟨_, _, h5, -⟩ := bind_ok h; exact (err_ok h5).elim
          · obtain ⟨_, _, h5, -⟩ := bind_ok h; exact (err_ok h5).elim
      · obtain ⟨_, _, h5, -⟩ := bind_ok h; exact (err_ok h5).elim
    · have hempty : s1.isEmpty = true → hat = c.pos := by
        intro he
        have : s1.toList = [] := by simpa using he
        rw [this] at hdec
        exact hdec.nil_eq
      have hret : ∀ (c5 : Cursor) (u : Unit), (DM.setPos c.pos).run (atPos c (hat + n)) = .ok (u, c5) →
          ∀ x c6, (retSeq fr).run c5 = .ok (x, c6) →
          ∀ q', q' = { op := .ret, ops := [.slot x.1, .imm (BitVec.ofNat 64 x.2)], pos := c.pos } →
          InsnRead fr ro c q' c6 := by
        intro c5 u h5 x c6 h6 q' hq'
        rw [run_setPos] at h5; cases h5
        subst hq'
        exact .ret (by rw [hc]; exact h6)
      have hisl : ∀ (c5 : Cursor) (u : Unit), (DM.setPos c.pos).run (atPos c (hat + n)) = .ok (u, c5) →
          ∀ isl opsRo site c6, (islandCall fr).run c5 = .ok ((isl, opsRo, site), c6) →
          ∀ ws, opsArray ro opsRo = some ws →
          InsnRead fr ro c { op := .island, ops := [.sym isl, .words ws], pos := c.pos, sites := [site], bare := fr.mode.pe } c6 := by
        intro c5 u h5 isl opsRo site c6 h6 ws hws
        rw [run_setPos] at h5; cases h5
        exact .island (by rw [hc]; exact h6) hws
      -- The pad region's `resume`.
      split at h
      · rename_i hres
        simp only [Bool.and_eq_true, beq_iff_eq] at hres
        obtain ⟨⟨hrg, he⟩, rfl⟩ := hres
        have := hempty he; subst this
        obtain ⟨at_, c5, h5, h⟩ := bind_ok h
        obtain ⟨rfl, hc5⟩ := pos_run' h5
        subst c5
        obtain ⟨y, c6, h6, h⟩ := bind_ok h
        obtain ⟨n2, hn2, rfl⟩ := run_item h6
        split at h
        · obtain ⟨_, _, h7, -⟩ := bind_ok h; exact (err_ok h7).elim
        rename_i hy
        have hy' : y = .ret := by simpa using hy
        subst hy'
        obtain ⟨rfl, rfl⟩ := pure_ok h
        exact .resume hrg hdh hn2
      by_cases hbr : ∃ cond t long, hd = .branch cond t long
      · obtain ⟨cond, t, long, rfl⟩ := hbr
        cases cond <;> dsimp only at h
        case always =>
          split at h
          · rename_i he
            obtain ⟨rfl, rfl⟩ := pure_ok h
            have := hempty he; subst this
            exact .jmp hdh
          · exact (err_ok h).elim
        all_goals exact (err_ok h).elim
      · cases hd <;> (try dsimp only at h)
        case branch => exact (hbr ⟨_, _, _, rfl⟩).elim
        case ld =>
          split at h
          · obtain ⟨u, c5, h5, h⟩ := bind_ok h
            obtain ⟨x, c6, h6, h⟩ := bind_ok h
            obtain ⟨rfl, rfl⟩ := pure_ok h
            exact hret _ _ h5 _ _ h6 _ rfl
          · exact (err_ok h).elim
        case sse =>
          split at h
          · obtain ⟨u, c5, h5, h⟩ := bind_ok h
            obtain ⟨x, c6, h6, h⟩ := bind_ok h
            obtain ⟨rfl, rfl⟩ := pure_ok h
            exact hret _ _ h5 _ _ h6 _ rfl
          · exact (err_ok h).elim
        case leave =>
          split at h
          · obtain ⟨u, c5, h5, h⟩ := bind_ok h
            obtain ⟨x, c6, h6, h⟩ := bind_ok h
            obtain ⟨rfl, rfl⟩ := pure_ok h
            exact hret _ _ h5 _ _ h6 _ rfl
          · exact (err_ok h).elim
        case popRbp =>
          split at h
          · obtain ⟨u, c5, h5, h⟩ := bind_ok h
            obtain ⟨x, c6, h6, h⟩ := bind_ok h
            obtain ⟨rfl, rfl⟩ := pure_ok h
            exact hret _ _ h5 _ _ h6 _ rfl
          · exact (err_ok h).elim
        case addRsp =>
          split at h
          · obtain ⟨u, c5, h5, h⟩ := bind_ok h
            obtain ⟨x, c6, h6, h⟩ := bind_ok h
            obtain ⟨rfl, rfl⟩ := pure_ok h
            exact hret _ _ h5 _ _ h6 _ rfl
          · exact (err_ok h).elim
        case callMem =>
          obtain ⟨u, c5, h5, h⟩ := bind_ok h
          obtain ⟨⟨isl, opsRo, site⟩, c6, h6, h⟩ := bind_ok h
          dsimp only at h
          split at h
          · rename_i ws hws
            obtain ⟨rfl, rfl⟩ := pure_ok h
            exact hisl _ _ h5 _ _ _ _ h6 _ hws
          · exact (err_ok h).elim
        case ud2 =>
          split at h
          · rename_i he
            obtain ⟨rfl, rfl⟩ := pure_ok h
            have := hempty he; subst this
            exact .unreachable hdh
          · exact (err_ok h).elim
        all_goals exact (err_ok h).elim


/-- `denseSwitch` leaves the cursor where it was when it finds none. -/
theorem denseSwitch_none {fr : Frame} {c c' : Cursor} (h : (denseSwitch fr).run c = .ok (none, c')) :
    c' = c := by
  unfold denseSwitch at h
  obtain ⟨x, c1, h1, h2⟩ := bind_ok h
  obtain ⟨rfl, rfl⟩ := get_run h1
  clear h
  split at h2
  · obtain ⟨_, c2, -, h⟩ := bind_ok h2
    obtain ⟨_, c3, -, h⟩ := bind_ok h
    split at h
    · cases (pure_ok h).1
    · exact (err_ok h).elim
  · exact (pure_ok h2).2.symm

/-- What `denseSwitch` finds is a handler call of a `switch.dense` opcode. -/
theorem denseSwitch_some {fr : Frame} {c c' : Cursor} {q : Proto}
    (h : (denseSwitch fr).run c = .ok (some q, c')) : ∃ w, q.op = denseOp w ∧ q.handler.isSome := by
  unfold denseSwitch at h
  obtain ⟨x, c1, h1, h2⟩ := bind_ok h
  obtain ⟨rfl, rfl⟩ := get_run h1
  clear h
  split at h2
  · rename_i w _ _ _ _ _
    obtain ⟨_, c2, -, h⟩ := bind_ok h2
    obtain ⟨_, c3, -, h⟩ := bind_ok h
    split at h
    · cases (pure_ok h).1; exact ⟨w, rfl, rfl⟩
    · exact (err_ok h).elim
  · cases (pure_ok h2).1

theorem insn_read {fr : Frame} {ro : ByteArray} {c c' : Cursor} {q : Proto}
    (h : (insn fr ro).run c = .ok (q, c')) : InsnRead fr ro c q c' := by
  unfold insn at h
  obtain ⟨r, c1, h1, h2⟩ := bind_ok h
  clear h
  cases r with
  | some p =>
    obtain ⟨rfl, rfl⟩ := pure_ok h2
    exact .dense h1
  | none =>
    have := denseSwitch_none h1
    subst this
    exact insnCore_read h2

/-! ### `arg` -/

theorem posOnly_run {α : Type} {x : DM α} {c c' : Cursor} {a : α} (hx : PosOnly x)
    (h : x.run c = .ok (a, c')) : c' = atPos c c'.pos := hx c a c' h

macro "posonly" : tactic => `(tactic| repeat (first
  | exact PosOnly.pure _ | exact PosOnly.pos | exact PosOnly.tryItem | exact PosOnly.setPos _
  | exact PosOnly.fuel | exact PosOnly.item | exact PosOnly.err _ _
  | refine PosOnly.forIn_range _ _ _ (fun _ _ => ?_)
  | refine PosOnly.forIn_list _ _ _ (fun _ _ => ?_)
  | refine PosOnly.bind ?_ (fun _ => ?_)
  | split | (dsimp only)))

/-- What `argInsn` reads: the stores `argStore a d` of an argument register to its slot, `a`
an `ArgReg` whose word `ArgReg.of?` accepts. -/
theorem argInsn_read {mode : Mode} {c c' : Cursor} {q : Proto}
    (h : (argInsn mode).run c = .ok (some q, c')) :
    ∃ (a : ArgReg) (d : BitVec 32), q = { op := .arg, ops := [.slot d, .imm (BitVec.ofNat 64 a.word)], pos := c.pos } ∧
      (ArgReg.of? a.word true).isSome ∧ Dec c c.pos (argStore a d mode.pe) c'.pos ∧
      c' = atPos c c'.pos := by
  unfold argInsn at h
  obtain ⟨p0, c1, h1, h⟩ := bind_ok h
  obtain ⟨rfl, hc1⟩ := pos_run' h1
  subst c1
  obtain ⟨fi, c2, h2, h⟩ := bind_ok h
  split at h
  case h_2 => obtain ⟨he, -⟩ := pure_ok h; cases he
  rename_i first
  have e2 := posOnly_run PosOnly.tryItem h2
  obtain ⟨r, c3, h3, h⟩ := bind_ok h
  have e3 := posOnly_run (by posonly) h3
  split at h
  case h_2 => obtain ⟨he, -⟩ := pure_ok h; cases he
  rename_i a0 mm
  obtain ⟨end_, c4, h4, h⟩ := bind_ok h
  obtain ⟨rfl, hc4⟩ := pos_run' h4
  subst c4
  obtain ⟨u, c5, h5, h⟩ := bind_ok h
  rw [run_setPos] at h5; cases h5
  split at h
  case h_2 => obtain ⟨he, -⟩ := pure_ok h; cases he
  rename_i a ha
  have hfa := Option.filter_eq_some_iff.mp ha
  obtain ⟨st, c6, h6, h⟩ := bind_ok h
  have hc3 : atPos c3 c.pos = c := by rw [e3, e2]
  rw [hc3] at h6
  let I : List Item → Option (Option Proto) × Unit → Cursor → Prop := fun pre st cur =>
    st.1 = none ∧ Dec c c.pos pre cur.pos ∧ cur = atPos c cur.pos
  let D : Option (Option Proto) × Unit → Cursor → Prop := fun st _ => st.1 = some none
  have key := forIn_list_pre I D _ ?step (argStore a mm.disp mode.pe) [] (none, ()) c c6 st
    ⟨rfl, .nil _, rfl⟩ h6
  case step =>
    intro pre w b cur r' cur' hI hr
    obtain ⟨-, hd, hc⟩ := hI
    obtain ⟨o, c7, h7, hr2⟩ := bind_ok hr
    by_cases hx : (o != some w) = true
    · simp only [hx, ↓reduceIte] at hr2
      obtain ⟨_, _, -, hr3⟩ := bind_ok hr2
      obtain ⟨rfl, -⟩ := pure_ok hr3
      rfl
    · simp only [hx, Bool.false_eq_true, ↓reduceIte] at hr2
      obtain ⟨rfl, rfl⟩ := pure_ok hr2
      have : o = some w := by simpa using hx
      subst this
      obtain ⟨n, hn, rfl⟩ := run_tryItem_some h7
      refine ⟨rfl, ?_, ?_⟩
      · rw [hc] at hn; exact hd.append (Dec.single hn)
      · rw [hc]
  rcases key with ⟨hst, hd, hc6⟩ | hst
  · dsimp only at h
    rw [hst] at h
    dsimp only at h
    obtain ⟨p7, c7, h7, h⟩ := bind_ok h
    obtain ⟨rfl, hc7⟩ := pos_run' h7
    subst c7
    split at h
    · obtain ⟨_, _, -, h8⟩ := bind_ok h
      obtain ⟨he, -⟩ := pure_ok h8; cases he
    · obtain ⟨he, rfl⟩ := pure_ok h
      cases he
      simp only [Bool.and_eq_true, beq_iff_eq] at hfa
      exact ⟨a, mm.disp, rfl, hfa.2.1, by simpa using hd, hc6⟩
  · dsimp only at h
    rw [hst] at h
    dsimp only at h
    obtain ⟨he, -⟩ := pure_ok h; cases he

end Ryo.Proofs.DecodeLink
