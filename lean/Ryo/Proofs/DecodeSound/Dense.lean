/-
Ryo.Proofs.DecodeSound.Dense — the dense switch as the decoder reads it (`dense_read`), its
handler's operands and `opSem` (`dense_opSem`), and its items (`dense_vt`): shared by
`bodySim_denseB` (`DecodeSound.lean`) and `regionSim_dense` (`DSWork/InlineRegion.lean`).
-/
import Ryo.Proofs.DecodeSound.Basic
import Ryo.Proofs.DSWork.Boundary
import Ryo.Proofs.DecodeSound.Region
import Ryo.Proofs.DSWork.Arg
import Ryo.Proofs.DSWork.Ret
import Ryo.Proofs.DSWork.Counter
import Ryo.Proofs.DSWork.Island
import Ryo.Proofs.DSWork.Call
import Ryo.Proofs.DSWork.Handler
import Ryo.Proofs.Dense
import Ryo.Proofs.DSWork.Inline
import Ryo.Proofs.DecodeLink.Bounds
import Ryo.Vm.Frame
import Ryo.Proofs.DecodeLink.Tables
import Ryo.Proofs.DecodeLink.CacheRegs
import Ryo.Proofs.Discharge.RelocsIn

set_option linter.constructorNameAsVariable false
set_option linter.unusedSimpArgs false

namespace Ryo.Proofs.DecodeSound

open Ryo.Spec Ryo.Vm Ryo.Vm.OpSem Ryo.X86 Ryo.Vm.Asm Ryo.Vm.R
open Ryo.Proofs.Inline Ryo.Proofs.Scope Ryo.Proofs.ScopeMem Ryo.Proofs.RegCache
open Ryo.Proofs.DecodeLink Ryo.Proofs.FrameBounds Ryo.Proofs.CacheMem
open Ryo.Proofs.Counter (CalleeSaved InStack TripContract)
open Ryo.Proofs.ArgRet (ArgsRel RetRel)
open Ryo.Proofs.Call (WorldRel Saved EntryAt CallContract)
open Ryo.Proofs.Island (IslandContract)

section Insn

variable {S : Setup} {code : ByteArray} {relocs : Array Reloc} {rodata : ByteArray}
  {callSites : Array CallSite} {dropped : Array DroppedStore} {scopes : Array R.Scope}
  {mode : Ryo.Obj.Mode}


/-- `denseItems.go`'s items, decoded one after the other up to the table's `lea`. -/
theorem denseItems_go_dec (c : Cursor) : ∀ (k p : Nat) (acc its : List Item) (at_ : Nat),
    denseItems.go c p acc k = some (its, at_) → ∃ l, its = acc.reverse ++ l ∧ Dec c p l at_
  | 0, p, acc, its, at_, h => by simp [denseItems.go] at h
  | k + 1, p, acc, its, at_, h => by
    unfold denseItems.go at h
    cases hdi : decodeItem { c with pos := p } with
    | none => rw [hdi] at h; cases h
    | some r =>
      obtain ⟨it, n⟩ := r
      have hit : decodeItem (atPos c p) = some (it, n) := hdi
      rw [hdi] at h
      cases it
      all_goals simp only [Bool.true_and, Bool.false_and, Bool.false_eq_true, ↓reduceIte,
        reduceCtorEq] at h
      all_goals (try split at h) <;> first
        | (cases h; done)
        | (cases h; exact ⟨[], by simp, .nil _⟩)
        | (obtain ⟨l, hl, hd⟩ := denseItems_go_dec c k _ _ its at_ h
           exact ⟨_ :: l, by simp [hl], .cons hit hd⟩)

theorem denseScan_some {c : Cursor} {w : W} {sl : BitVec 32} {base n : BitVec 64} {at_ : Nat}
    (h : denseScan c = some (w, sl, base, n, at_)) :
    ∃ its, Dec c c.pos its at_ ∧ Asm.denseIndex (denseOp w) sl base n = some its := by
  unfold denseScan at h
  cases hd : denseItems c with
  | none => simp [hd] at h
  | some r =>
    obtain ⟨its, at'⟩ := r
    obtain ⟨l, hl, hdec⟩ := denseItems_go_dec c 7 c.pos [] its at' hd
    simp only [List.reverse_nil, List.nil_append] at hl
    have hdec' : Dec c c.pos its at' := by rw [hl]; exact hdec
    clear hdec hl
    refine ⟨its, ?_⟩
    simp only [hd, bind, Option.bind] at h
    -- Every branch but the last check's success ends in `none`; which matches `split` takes
    -- first (`base`'s included) doesn't matter.
    repeat' split at h
    all_goals (try simp only [bind, Option.bind, reduceCtorEq] at h)
    all_goals (try (cases h; done))
    all_goals (try (simp at h; done))
    all_goals
      simp only [Option.some.injEq, Prod.mk.injEq] at h
      obtain ⟨rfl, rfl, rfl, rfl, rfl⟩ := h
      refine ⟨hdec', ?_⟩
      simp_all [Bool.or_eq_true, bne_iff_ne]

/-- What `denseSwitch` read at `c`: `Asm.denseIndex`'s items (the index computation) then the
jump table (`table`, `table_read`), as the `switch.dense` handler call with the arguments
`denseArgs` gives. -/
theorem dense_read {fr : Vm.Frame} {c c' : Cursor} {q : Proto}
    (h : (denseSwitch fr).run c = .ok (some q, c')) :
    ∃ (w : W) (sl : BitVec 32) (base n : BitVec 64) (its : List Item) (at_ : Nat)
      (tb : BitVec 32) (pE : Nat) (args : List R.Arg) (es : List (BitVec 32)),
      Asm.denseIndex (denseOp w) sl base n = some its ∧
      q = { op := denseOp w, handler := some (args, .table (es.map (·.toNat))), pos := c.pos } ∧
      denseArgs fr (denseOp w) sl base n = some args ∧
      Dec c c.pos its at_ ∧ Dec c at_ (Switch.switchItems tb) pE ∧
      (∀ i (hi : i < es.length), (atPos c (tb.toNat + 4 * i)).tableEntry tb = some es[i]) := by
  unfold denseSwitch at h
  obtain ⟨x, c1, h1, h2⟩ := bind_ok h
  obtain ⟨rfl, rfl⟩ := get_run h1
  split at h2
  · rename_i w sl base n at_ hscan
    obtain ⟨its, hd1, hden⟩ := denseScan_some hscan
    obtain ⟨u, c2, h3, h⟩ := bind_ok h2
    rw [run_setPos] at h3
    cases h3
    obtain ⟨ts, c3, h4, h⟩ := bind_ok h
    obtain ⟨tb, pE, es, hdT, rfl, hes, -⟩ := table_read h4
    split at h
    · rename_i args hargs
      obtain ⟨e, -⟩ := pure_ok h
      cases e
      exact ⟨w, sl, base, n, its, at_, tb, pE, args, es, hden, rfl, hargs, hd1,
        Dec.at_iff.1 hdT, hes⟩
    · exact (err_ok h).elim
  · obtain ⟨e, -⟩ := pure_ok h2; cases e

/-! The `switch.dense` handlers' tables and `opSem`. -/

set_option maxRecDepth 100000 in
theorem dense_handler (w : W) :
    (denseOp w).handler? = some ⟨.switch_dense, [tyName false w], some "usize"⟩ := by
  cases w <;> rfl

set_option maxRecDepth 100000 in
theorem dense_operands (w : W) :
    (denseOp w).info.operands = [⟨"s", .slot⟩, ⟨"base", immKind w⟩, ⟨"default", .target⟩,
      ⟨"table", .list .target⟩] := by
  cases w <;> rfl

theorem fp_dense {ty : String} {ps : List String} {n : Nat} (h : tySize ty = some n) :
    footprintOf .switch_dense (ty :: ps) = some { reads := [rdA "s" n], flow := .table } := by
  simp only [footprintOf, List.head?, Option.bind_some, h]
  try rfl

/-- `switch_dense` at `n` bytes: the slot's value minus `base`, clamped to the table length;
no writes. -/
theorem opSem_dense {op : Full.Opcode} {r : Option String} {ty : String} {n : Nat} {sg : Bool}
    {k : OperandKind} {s : Int} {b len : Nat} {st st' : OpSem.State} {ch : OpSem.Choice}
    {c : Control}
    (hh : op.handler? = some ⟨.switch_dense, [ty], r⟩) (hty : Ty.parse ty = some (.int n sg))
    (ho : op.info.operands = [⟨"s", .slot⟩, ⟨"base", k⟩, ⟨"default", .target⟩,
      ⟨"table", .list .target⟩])
    (hsem : opSem op [.slot s, .imm b, .none, .targets len] st ch = .ok (c, st')) :
    ∃ bs v, st.readFrame s n = .ok bs ∧ asNat bs = .ok v ∧
      c = .index (if (BitVec.ofNat (8 * n) v - BitVec.ofNat (8 * n) b).toNat < len
        then (BitVec.ofNat (8 * n) v - BitVec.ofNat (8 * n) b).toNat else len) ∧ st' = st := by
  oinv hsem, hh, fp_dense (ps := []) (tySize_of_parse hty)
  osimp [ho] at hra
  obtain ⟨bs, hr, rfl⟩ := hra
  osimp [ho, intTy_of_parse hty] at hk
  obtain ⟨v, hv, rfl⟩ := hk
  exact ⟨bs, v, hr, hv, rfl, commit_nil hc⟩

theorem dense_nb (w : W) (vals : Operands) (st : OpSem.State) :
    NoNB (opSem (denseOp w) vals st {}) := by
  have hh := dense_handler w
  unfold opSem
  refine noNB_bind ?_ fun ⟨h, fp, val⟩ hp => ?_
  · unfold prepare
    intro m hm
    simp only [hh, bind, Except.bind] at hm
    repeat' split at hm
    all_goals first | (cases hm; done) | (cases hm; simp [inline_ill_eq, inline_throw_eq] at *) |
      simp_all [inline_ill_eq, inline_throw_eq]
  have hh' := prepare_handler hp
  rw [hh] at hh'
  cases hh'
  refine noNB_bind ?_ fun reads _ => ?_
  · unfold readAll
    refine noNB_mapM _ (fun a => ?_) _
    split
    · exact noNB_bind (noNB_readFrame _ _ _) fun _ _ => noNB_pure _
    · exact noNB_ill _
  have hrd : ∀ n, NoNB ((mkEnv reads val st {}).rd n) := fun n => by
    unfold mkEnv; dsimp only; split
    · exact noNB_pure _
    · exact noNB_ill _
  refine noNB_bind ?_ fun o _ => ?_
  · unfold kindSem; dsimp only; inline_nb
  refine noNB_bind ?_ fun _ _ => noNB_pure _
  unfold commit
  refine noNB_foldlM _ (fun st w => ?_) _ _
  unfold commitOne
  split
  · exact noNB_ill _
  · split
    · exact noNB_ill _
    · split
      · exact noNB_writeFrame _ _ _
      · exact noNB_ill _

/-- `denseArgs`'s registers: `fp` first with `fpArg` off PE (PE's layout is the `rbp` one, `s`
overwriting `fp`), then `s`, `base` and the case count. -/
def denseRegs (fa pe : Bool) (sl : BitVec 32) (base n : BitVec 64) : List R.Arg :=
  (if fa && !pe then [.fp] else []) ++ [.imm (sl.setWidth 64), .imm base, .imm n]

set_option maxRecDepth 100000 in
theorem dense_args_eq (fsz : Nat) (md : Ryo.Obj.Mode) (rg : Bool) (w : W) (sl : BitVec 32)
    (base n : BitVec 64) :
    denseArgs ⟨fsz, md, rg⟩ (denseOp w) sl base n = some (denseRegs md.fpArg md.pe sl base n) := by
  obtain ⟨fa, fp, al, pe, ct⟩ := md
  cases fa <;> cases pe <;> cases w <;> rfl

set_option maxRecDepth 100000 in
theorem dense_layout (w : W) (fa pe : Bool) : (denseOp w).layout fa pe =
    some (if pe then ⟨[⟨0, 0, 1, false⟩, ⟨1, 0, 1, false⟩, ⟨0, 0, 0, false⟩, ⟨2, 0, 1, false⟩], 0, 3⟩
      else if fa then ⟨[⟨1, 0, 1, false⟩, ⟨2, 0, 1, false⟩, ⟨0, 0, 0, false⟩, ⟨3, 0, 1, false⟩], 1, 4⟩
      else ⟨[⟨0, 0, 1, false⟩, ⟨1, 0, 1, false⟩, ⟨0, 0, 0, false⟩, ⟨2, 0, 1, false⟩], 0, 3⟩) := by
  cases w <;> cases fa <;> cases pe <;> rfl

set_option maxRecDepth 100000 in
theorem dense_shape (w : W) : (denseOp w).info.shape = .switch := by
  cases w <;> rfl

/-- The operands `R.unpack` gives for `denseArgs`'s registers: the slot, `base`, no default
(not passed), the table of `n` cases. -/
theorem dense_vals {ρ : R.Addrs} {fr : Vm.Frame} {w : W} {sl : BitVec 32} {base n : BitVec 64}
    {args : List R.Arg} {vals : Operands}
    (hargs : denseArgs fr (denseOp w) sl base n = some args)
    (hu : R.unpack ρ (denseOp w) fr.mode args = some vals) :
    vals = [.slot sl.toInt, .imm base.toNat, .none, .targets n.toNat] := by
  obtain ⟨fsz, md, rg⟩ := fr
  rw [dense_args_eq] at hargs
  cases hargs
  have hs : (sl.setWidth 64).toNat < 2 ^ 32 := by
    rw [Dense.toNat_zext sl (by decide)]; exact sl.isLt
  have hsl : R.int32 (sl.setWidth 64).toNat = sl.toInt := by
    unfold R.int32
    rw [Dense.toNat_zext sl (by decide), BitVec.ofNat_toNat, BitVec.setWidth_eq]
  have hsl3 : R.int32 sl.toNat = sl.toInt := by
    rw [← hsl, Dense.toNat_zext sl (by decide)]
  have hsl4 : R.int32 (sl.toNat % 2 ^ 64) = sl.toInt := by
    rw [Nat.mod_eq_of_lt (Nat.lt_trans sl.isLt (by decide))]; exact hsl3
  have hs3 : sl.toNat < 2 ^ 32 := sl.isLt
  have hs4 : sl.toNat % 2 ^ 64 < 2 ^ 32 := by
    rw [Nat.mod_eq_of_lt (Nat.lt_trans sl.isLt (by decide))]; exact hs3
  obtain ⟨fa, fp, al, pe, ct⟩ := md
  simp only at hu
  cases fa <;> cases pe <;> cases w <;>
    simp [R.unpack, R.unpackOpnd, R.regImm, denseRegs, dense_layout, dense_operands, dense_shape,
      immKind, hs, hs3, hs4, hsl, hsl3, hsl4] at hu <;>
    first
      | exact hu.symm
      | exact hu.2.symm
      | (obtain ⟨-, hu⟩ := hu; exact hu.symm)
      | (subst hu; rfl)
      | (obtain ⟨-, rfl⟩ := hu; rfl)
      | (by_cases hb : base.toNat < 256 <;> simp [hb] at hu <;> first | exact hu | exact hu.symm)
      | (by_cases hb : base.toNat < 65536 <;> simp [hb] at hu <;> first | exact hu | exact hu.symm)
      | (by_cases hb : base.toNat < 4294967296 <;> simp [hb] at hu <;>
          first | exact hu | exact hu.symm)

/-- `switch.dense`'s `opSem` from the frame related to `x` (`Rel`): the case index `denseIdx`
of the slot's bytes in `x` (`Dense.denseIdx_opSem`, `read_int`), the state unchanged. -/
theorem dense_opSem {w : W} {sl : BitVec 32} {base n : BitVec 64} {args : List R.Arg}
    {vals : Operands} {st : OpSem.State} {x : X86.State}
    (hargs : denseArgs S.fr (denseOp w) sl base n = some args)
    (hu : R.unpack S.c.ρ (denseOp w) S.c.mode args = some vals)
    (hrel : Rel st x) (hno : Handler.NoUB (denseOp w) vals st) :
    ∃ ch, opSem (denseOp w) vals st ch =
      .ok (.index (Dense.denseIdx w (x.memW w (x.ea (M.frame sl))) base n), st) := by
  have hv := dense_vals (fr := S.fr) hargs hu
  subst hv
  cases hs : opSem (denseOp w) [.slot sl.toInt, .imm base.toNat, .none, .targets n.toNat] st {}
    with
  | error e =>
    obtain ⟨m, rfl⟩ := hno {} _ hs
    exact absurd hs (dense_nb w _ st m)
  | ok r =>
    obtain ⟨ctl, st'⟩ := r
    obtain ⟨bs, v, hrd, hvv, rfl, rfl⟩ :=
      opSem_dense (dense_handler w) (tyName_parse w).1 (dense_operands w) hs
    refine ⟨{}, ?_⟩
    rw [hs]
    have hn : wbytes w ≤ 16 := by cases w <;> decide
    have hval := read_int hrel hn hrd hvv
    have hk : w.bits = 8 * wbytes w := by cases w <;> rfl
    have e := Dense.denseIdx_opSem w (x.memW w (x.ea (M.frame sl))) base n (wbytes w) v
      base.toNat n.toNat hk (by
        rw [memW_eq, ea_frame, BitVec.toNat_ofNat, ← wbytes_eq, hval])
      rfl rfl
    rw [e]

/-- `FrameCore` after the scopes, the machine state unchanged (no handler call; PE's pad region
too). -/
theorem dense_frameCore (H : Hyps S) {s s1 : R.RState} {x : X86.State} {pc : Nat}
    (hf : FrameCore S s x) (hsc : (S.c.scopesAt s.pc).foldlM R.applyScope s = .ok s1)
    (hnl : ¬ LeadArg S pc) : FrameCore S { s1 with pc, st := s1.st } x := by
  have hk := scopes_keeps _ hsc
  have hfb := H.frameBounds
  have hwinT : (s.fp : Int) + S.K ≤ 2 ^ 64 := hf.win
  obtain ⟨hr1, hsep1⟩ := sep_foldlM _ (hfb.scopesIn s.pc) (hfb.window hwinT) hf.rrel hf.sep hsc
  obtain ⟨-, hm1⟩ := memRel_foldlM _ (hfb.scope_size _) hf.rrel hf.mem hsc
  refine ⟨⟨hr1.rel, hr1.rbp, hr1.wf⟩, hm1, hsep1, ?_, ?_, hf.code, hf.ro,
    hf.frame, (H.slots_scopes_core (s1 := s1) hf hsc :),
    (hf.esc.scopes hsc).of_not hnl⟩
  · show (s1.fp : Int) + S.K ≤ 2 ^ 64
    rw [hk.fp]; exact hwinT
  · show S.F ≤ s1.fp
    rw [hk.fp]; exact hf.fpF

/-- `FrameInv` after the scopes, the machine state unchanged (no handler call). -/
theorem dense_frameInv (H : Hyps S) {s s1 : R.RState} {x : X86.State} {pc : Nat}
    (hf : FrameInv S s x) (hsc : (S.c.scopesAt s.pc).foldlM R.applyScope s = .ok s1)
    (hnl : ¬ LeadArg S pc) : FrameInv S { s1 with pc, st := s1.st } x :=
  FrameInv.ofCore (dense_frameCore H hf.toCore hsc hnl) hf.rsp hf.room (fun ha => absurd ha hnl)

theorem dense_switch_canon (tb : BitVec 32) (p : Nat) : Canon (Switch.switchItems tb) p := by
  have c : ∀ (i : Item) (p : Nat), i.wf (BitVec.ofNat 32 p) = true →
      (∀ b e, i ≠ .tableEntry b e) → i.Canonical p := fun _ _ hw ht => ⟨ht, .inl hw⟩
  refine ⟨c _ _ rfl ?_, c _ _ rfl ?_, c _ _ rfl ?_, c _ _ rfl ?_, trivial⟩ <;>
    intro _ _ h <;> cases h

/-- The dense switch's items before its `jmp rax` as `steps_of_run_last_fb` needs them without a
frame pointer (`VtItem`: canonical in their `spFrame` form, `rbp` only a memory base, `rsp` kept,
falling through with memory kept, `rip`-free), and the `jmp rax` (no memory operand). -/
theorem dense_vt (ctx : Ctx) (F : BitVec 32) {w : W} {sl : BitVec 32} {base n : BitVec 64}
    {its : List Item} (_h : Asm.denseIndex (denseOp w) sl base n = some its) (tb : BitVec 32) :
    (∀ i ∈ its ++ [Item.leaTable tb, Item.loadTableEntry, Item.addRaxRcx], VtItem ctx F i) ∧
      Item.jmpRax.RbpFree ∧ ∀ p, (FForm.item (some F) Item.jmpRax).Canonical p := by
  have vt : ∀ {it : Item}, cacheSafe it = true → CacheStep.wfAny it = true →
      CacheStep.noRsp it = true → it.FallsThrough ctx ∧ it.MemKept ctx → VtItem ctx F it :=
    fun hs hw hn hf =>
      ⟨fun p => CacheStep.canon_sp_of hw F p, CacheStep.rbpFree_of hs hw,
        CacheStep.rspKept_of hs hw hn, hf.1, hf.2, fun s a => exec_jump hs s a⟩
  have reg : ∀ {it : Item}, FForm.item (some F) it = it → it.wf 0 = true →
      (∀ b e, it ≠ .tableEntry b e) → (∀ p, it.wf p = it.wf 0) → it.RbpFree → it.RspKept ctx →
      it.FallsThrough ctx ∧ it.MemKept ctx → it.RipFree ctx → VtItem ctx F it :=
    fun he hw ht hp hb hr hf hrip =>
      ⟨fun p => by rw [he]; exact ⟨ht, .inl (by rw [hp]; exact hw)⟩, hb, hr, hf.1, hf.2, hrip⟩
  refine ⟨fun i hi => ?_, rfl, fun p => ⟨fun _ _ h => (by cases h), .inl rfl⟩⟩
  rcases List.mem_append.1 hi with hi | hi
  · have hok := Dense.dense_items_ok ctx _h i hi
    obtain ⟨-, rfl⟩ := Dense.denseIndex_some _h
    rcases List.mem_cons.1 hi with rfl | hi
    · exact vt (by cases w <;> rfl) (by cases w <;> rfl) rfl hok
    rcases List.mem_append.1 hi with hi | hi
    · unfold Dense.subItems at hi
      split at hi
      · cases hi
      · split at hi
        · simp only [List.mem_cons, List.not_mem_nil, or_false] at hi
          rcases hi with rfl | rfl
          · exact vt rfl rfl rfl hok
          · exact vt rfl rfl rfl hok
        · simp only [List.mem_cons, List.not_mem_nil, or_false] at hi
          subst hi
          refine vt rfl ?_ rfl hok
          cases w
          · simp only [CacheStep.wfAny, Item.wf, Asm.sextI32, Dense.fits8, Bool.and_true] <;> rfl
          · simp only [CacheStep.wfAny, Item.wf, Asm.sextI32, Dense.fits16, Bool.and_true] <;> rfl
          · rfl
          · rfl
    · simp only [Dense.tailItems, List.mem_cons, List.not_mem_nil, or_false] at hi
      rcases hi with rfl | rfl | rfl
      · exact vt rfl rfl rfl hok
      · exact vt rfl (by split <;> rfl) rfl hok
      · exact vt rfl rfl rfl hok
  · simp only [List.mem_cons, List.not_mem_nil, or_false] at hi
    rcases hi with rfl | rfl | rfl
    · refine reg rfl rfl (fun _ _ h => nomatch h) (fun _ => rfl) rfl ?_ (Switch.leaTable_straight ctx tb)
        (by intro s a; rfl)
      intro y y' he; cases Switch.except_ok_inj he; rfl
    · refine reg rfl rfl (fun _ _ h => nomatch h) (fun _ => rfl) rfl ?_ (Switch.loadTableEntry_straight ctx)
        (by intro s a; rfl)
      intro y y' he; cases Switch.except_ok_inj he; rfl
    · refine reg rfl rfl (fun _ _ h => nomatch h) (fun _ => rfl) rfl ?_ (Switch.addRaxRcx_straight ctx)
        (by intro s a; rfl)
      intro y y' he; cases Switch.except_ok_inj he; rfl
end Insn

end Ryo.Proofs.DecodeSound
