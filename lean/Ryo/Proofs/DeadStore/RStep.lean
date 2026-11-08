/-
Ryo.Proofs.DeadStore.RStep — R-level transfer for non-inline instructions (design T3; statements
from T0).

The environment acts on the real machine, so a non-inline step runs from the shadow
`erase s P` (`Rel.frameInvR_erase`). These lemmas turn the shadow's transition back into R's own
from `s`, with the same answer: gen ⊇ reads, kill ⊆ writes, per shape of `Frame.effects` against
`R.step`. The successors differ only at `P'` (the bytes of `P` not written), where the shadow's
is `Uninit`, and `P'` is again a patch set (liveness transfer, `Fix.lean`; a byte an `End` makes `Uninit` stays only
while the cache covers it, else the ghost is re-chosen there, `Rel.ghost_drop_uninit`); escape soundness carries over (`Esc.lean`'s `escPre_next`).

Split: T3a handlers (`opSem_reads_footprint`, `opSem_frame_writes`, `FootprintExact`) and the
assembly `rnext_erase`; T3b calls, tail calls, `ret` (the same `Query`: private bytes aren't in
the world, `FactsAgree` for the stack area and sret) with `rdone_erase`, `rsafe_erase`; T3c scopes
and the other natives (island, `arg`, `jmp`, `lpad`, `resume`, `unreachable`).
-/
import Ryo.Proofs.DeadStore.Defs
import Ryo.Proofs.DeadStore.Rel
import Ryo.Proofs.DeadStore.Names
import Ryo.Proofs.DeadStore.Covered
import Ryo.Proofs.MnemonicChars

namespace Ryo.Proofs.DeadStore

open Ryo.Spec Ryo.Vm Ryo.Vm.R Ryo.X86 Ryo.Proofs.DecodeSound Ryo.Proofs.DecodeLink

variable {S : Setup}

/-- What every non-inline transfer lemma assumes of `s` and `P`. -/
structure StepPre (S : Setup) (C : Cert S) (s : R.RState) (P : Int → Prop) : Prop where
  hyps : Hyps S
  facts : FactsAgree C.facts S.c
  fpExact : FootprintExact
  patch : PatchOk S C s P
  esc : EscSound S C s
  lt : s.pc < S.c.d.insns.size
  /-- The ghost's `FrameInvR` (R-side well-formedness: `EscWF`, `FrameSep`, the slots). -/
  frame : ∃ xh, FrameInvR S s xh
  safe : RSafe S.Safe S.c s
  notInline : ¬ InlineAt S s.pc
  /-- A handler instruction's successors are instructions (the decoder's target checks;
  **to be discharged** in T6). -/
  succRange : ∀ h args t, S.c.d.insns[s.pc]? = some (.handler h args t) →
    ∀ ctl y, t.succ s.pc ctl = some y → y ≤ S.c.d.insns.size
  /-- The landing pad of `pc`'s cleanup entry is an instruction (**to be discharged** in T6). -/
  padRange : ∀ pad b, S.c.cleanupAt s.pc = some (some pad, b) → pad < S.c.d.insns.size
  /-- A `jmp`'s target is an instruction (**to be discharged** in T6). -/
  jmpRange : ∀ op f t, S.c.d.insns[s.pc]? = some (.native op [.target t]) → op.full = some f →
    f.info.shape = .jmp → t < S.c.d.insns.size
  /-- An `arg` isn't the last instruction (**to be discharged** in T6). -/
  argNext : ∀ op f d r, S.c.d.insns[s.pc]? = some (.native op [.slot d, .imm r]) →
    op.full = some f → f.info.shape = .arg → s.pc + 1 ≤ S.c.d.insns.size
  /-- An `arg` is a leading one: every instruction before it is an `arg` (**to be discharged**
  from the decoder's `ArgsLeadCheck`). -/
  argLead : ∀ op f d r, S.c.d.insns[s.pc]? = some (.native op [.slot d, .imm r]) →
    op.full = some f → f.info.shape = .arg → ∀ j < s.pc, ∃ op' f' d' r',
      S.c.d.insns[j]? = some (.native op' [.slot d', .imm r']) ∧ op'.full = some f' ∧
      f'.info.shape = .arg
  /-- At a leading `arg`, the incoming register it reads holds its size's bytes (**to be
  discharged** from the entry / `ArgsLive` invariant). -/
  argLen : ∀ op f d r a, S.c.d.insns[s.pc]? = some (.native op [.slot d, .imm r]) →
    op.full = some f → f.info.shape = .arg →
    (∀ j < s.pc, ∃ op' f' d' r',
      S.c.d.insns[j]? = some (.native op' [.slot d', .imm r']) ∧ op'.full = some f' ∧
      f'.info.shape = .arg) →
    Asm.ArgReg.of? r.toNat true = some a → a.size ≤ (s.args.get (.ofArgReg a)).length
  /-- An island isn't the last instruction (**to be discharged** in T6). -/
  islandNext : ∀ op f isl ws, S.c.d.insns[s.pc]? = some (.native op [.sym isl, .words ws]) →
    op.full = some f → f.info.shape = .island → s.pc + 1 ≤ S.c.d.insns.size
  /-- A call isn't the last instruction (**to be discharged** in T6, as `islandNext`). -/
  callNext : ∀ op ops f, S.c.d.insns[s.pc]? = some (.native op ops) →
    op.full = some f → f.info.shape = .call → s.pc + 1 ≤ S.c.d.insns.size
  /-- A native instruction's successors are instructions (**to be discharged** in T6). -/
  nativeRange : ∀ op ops f t ctl y, S.c.d.insns[s.pc]? = some (.native op ops) →
    op.full = some f → R.nativeCtl f ops = some t → t.succ s.pc ctl = some y →
    y ≤ S.c.d.insns.size

/-- R's own transition from `s` matching the shadow's to `t'`. -/
def StepOut (S : Setup) (C : Cert S) (s : R.RState) (P : Int → Prop) (t' : R.RState) : Prop :=
  ∃ s' P', (∀ o, P' o → P o) ∧
    (s'.pc ∈ C.fl.pad[s.pc]! ∨
      ∀ o, P' o → InFrame S o → C.fl.kill[s.pc]!.bits.testBit (bit S o) = false) ∧
    (∀ o, P' o → InFrame S o → s'.pc ∈ C.fl.succ[s.pc]! →
      C.fl.ends[s.pc]!.bits.testBit (bit S o) = true → s'.st.byteAt o = .ok .uninit) ∧ RNext S.c s s' ∧ RAgree P' s' t' ∧ (∀ o, P' o → t'.st.byteAt o = .ok .uninit) ∧
    PatchOk S C s' P' ∧ (s'.pc < S.c.d.insns.size → EscSound S C s')

/-! ### Answers (T3b/T3c) -/

/-- What the dead-store transfer needs of an environment's answer at `s`'s call or island (the
flow's sure writes are written): an island's answer gives the bytes of every `Lend` extent, and a
call's returned registers hold their widths' bytes. **Discharged in Sim.lean** from how answers are
built from the x86 callee or island (full-width registers, the extents written). -/
def AnswerOk (S : Setup) (s : R.RState) (a : R.Answer) : Prop :=
  (∀ op isl ws, S.c.d.insns[s.pc]? = some (.native op [.sym isl, .words ws]) →
    a.frame.length = (S.c.lendsAt s.pc).length) ∧
  (∀ regs, a.result = .ret regs → ∀ r : R.Reg, r.width ≤ (regs.get r).length)

/-- A call, tail call or `ret` (T3b's shapes). -/
def CallLike (S : Setup) (k : Nat) : Prop :=
  ∃ op ops, S.c.d.insns[k]? = some (.native op ops) ∧
    (op.info.shape = .call ∨ op.info.shape = .tailCall ∨ op.info.shape = .ret)

/-! ### The liveness of the `Escape` ranges (T3c) -/

theorem forIn'_push_size {β : Type} : ∀ (l : List Nat) (init : Array β)
    (f : (a : Nat) → a ∈ l → Array β → Id (ForInStep (Array β))),
    (∀ a h b, ∃ x, f a h b = pure (ForInStep.yield (b.push x))) →
    (forIn' l init f).run.size = init.size + l.length
  | [], init, f, _ => by simp
  | a :: l, init, f, hf => by
    obtain ⟨x, hx⟩ := hf a (List.mem_cons_self ..) init
    have ih := forIn'_push_size l (init.push x) (fun a h b => f a (List.mem_cons_of_mem _ h) b)
      (fun a h b => hf a _ b)
    simp only [List.forIn'_cons, hx, pure_bind]
    rw [ih]
    simp only [Array.size_push, List.length_cons]
    omega

/-- `flow` has one successor list per instruction. -/
theorem flow_succ_size (d : Decoded) : (Frame.flow d).1.size = d.insns.size := by
  unfold Frame.flow
  simp only [Id.run_bind, Id.run_pure, Std.Legacy.Range.forIn'_eq_forIn'_range',
    Std.Legacy.Range.size]
  rw [forIn'_push_size]
  · simp
  · intro a h b
    exact ⟨_, rfl⟩

theorem flowOf_succ {d : Decoded} {mode : Ryo.Obj.Mode} {facts : Frame.Facts} {fl : Frame.Flow}
    (h : Frame.Flow.of d mode facts = .ok fl) : fl.succ = (Frame.flow d).1 := by
  unfold Frame.Flow.of at h
  simp only [bind, Except.bind] at h
  split at h
  · cases h
  · simp only [pure, Except.pure, Except.ok.injEq] at h
    subst h
    rfl

theorem scopesAt_foldr_mem (L : List ((Nat × R.Scope) × Nat)) (A : Array (List (Nat × R.Scope)))
    (f : (Nat × R.Scope) × Nat → Array (List (Nat × R.Scope)) → Array (List (Nat × R.Scope)))
    (hf : ∀ k sc j a, f ((k, sc), j) a = if k < a.size then a.modify k ((j, sc) :: ·) else a) :
    (L.foldr f A).size = A.size ∧
      ∀ x ∈ L, x.1.1 < A.size → ∃ l, (L.foldr f A)[x.1.1]? = some l ∧ (x.2, x.1.2) ∈ l := by
  induction L with
  | nil => exact ⟨rfl, fun x hx => by cases hx⟩
  | cons y L ih =>
    obtain ⟨⟨k, sc⟩, j⟩ := y
    obtain ⟨hsz, hmem⟩ := ih
    rw [List.foldr_cons, hf]
    by_cases hk : k < (L.foldr f A).size
    · rw [if_pos hk]
      refine ⟨by rw [Array.size_modify, hsz], fun x hx hxl => ?_⟩
      rw [Array.getElem?_modify]
      rcases List.mem_cons.1 hx with rfl | hx
      · dsimp only
        rw [if_pos rfl, Array.getElem?_eq_getElem hk]
        exact ⟨_, rfl, List.mem_cons_self ..⟩
      · obtain ⟨l, hl, hm⟩ := hmem x hx hxl
        by_cases he : k = x.1.1
        · rw [if_pos he, hl]
          exact ⟨_, rfl, List.mem_cons_of_mem _ hm⟩
        · rw [if_neg he]
          exact ⟨l, hl, hm⟩
    · rw [if_neg hk]
      refine ⟨hsz, fun x hx hxl => ?_⟩
      rcases List.mem_cons.1 hx with rfl | hx
      · exact absurd (by rw [hsz]; exact hxl) hk
      · exact hmem x hx hxl

/-- Scope `j` before instruction `k` is in `Frame.scopesAt d`'s row `k`. -/
theorem frame_scopesAt_mem {d : Decoded} {j k : Nat} {sc : R.Scope}
    (hj : d.scopes[j]? = some (k, sc)) (hk : k < d.insns.size) :
    (j, sc) ∈ (Frame.scopesAt d)[k]! := by
  have h := scopesAt_foldr_mem d.scopes.toList.zipIdx (Array.replicate d.insns.size [])
    (fun x a => if x.1.1 < a.size then a.modify x.1.1 ((x.2, x.1.2) :: ·) else a)
    (fun _ _ _ _ => rfl)
  have hx : ((k, sc), j) ∈ d.scopes.toList.zipIdx :=
    List.mem_zipIdx_iff_getElem?.2 (by rw [Array.getElem?_toList]; exact hj)
  obtain ⟨l, hl, hm⟩ := h.2 _ hx (by simpa using hk)
  have he : Frame.scopesAt d = d.scopes.toList.zipIdx.foldr
      (fun x a => if x.1.1 < a.size then a.modify x.1.1 ((x.2, x.1.2) :: ·) else a)
      (Array.replicate d.insns.size []) := by
    unfold Frame.scopesAt
    rw [← Array.foldr_toList, Array.toList_zipIdx]
    all_goals rfl
  rw [he]
  dsimp only at hl hm
  simp only [Array.getElem!_eq_getD, Array.getD_eq_getD_getElem?, hl, Option.getD_some]
  exact hm

/-- An `Escape` scope before `k` makes its range part of `k`'s operand reads. -/
theorem flowOf_operand_escape {d : Decoded} {mode : Ryo.Obj.Mode} {facts : Frame.Facts}
    {fl : Frame.Flow} (h : Frame.Flow.of d mode facts = .ok fl) {k : Nat} (hk : k < d.insns.size)
    {j : Nat} {sc : R.Scope} {a : Nat} (hm : (j, sc) ∈ (Frame.scopesAt d)[k]!)
    (hkind : sc.kind = .escape a) {i : Nat}
    (h1 : (Frame.range d.frameSize sc.frameOffset sc.size).1 ≤ i)
    (h2 : i < (Frame.range d.frameSize sc.frameOffset sc.size).2) :
    (fl.operand[k]!).bits.testBit i = true := by
  unfold Frame.Flow.of at h
  simp only [bind, Except.bind] at h
  split at h
  · cases h
  · rename_i rows hr
    simp only [pure, Except.pure, Except.ok.injEq] at h
    subst h
    obtain ⟨r, hrow, hr2⟩ := mapM_except_ok _ _ rows hr k (by simpa using hk)
    have hpt : (((rows.map Frame.Flow.Row.operand).toArray)[k]!) = r.operand := by
      simp [Array.getElem!_eq_getD, Array.getD_eq_getD_getElem?, hr2]
    show ((((rows.map Frame.Flow.Row.operand).toArray)[k]!)).bits.testBit i = true
    rw [hpt]
    simp only [List.getElem_range] at hrow
    unfold Frame.Flow.row at hrow
    simp only [bind, Except.bind] at hrow
    split at hrow
    · cases hrow
    · simp only [pure, Except.pure, Except.ok.injEq] at hrow
      subst hrow
      rw [testBit_rangesBits]
      refine List.any_eq_true.2 ⟨Frame.range d.frameSize sc.frameOffset sc.size, ?_, by simp [h1, h2]⟩
      simp only [Frame.Flow.rowOf]
      refine List.mem_append_right _ (List.mem_filterMap.2 ⟨(j, sc), hm, ?_⟩)
      simp [hkind]

/-- An `Escape` scope before `k` makes its range part of `k`'s `escRead` (`Flow.rowOf`). -/
theorem flowOf_escRead_escape {d : Decoded} {mode : Ryo.Obj.Mode} {facts : Frame.Facts}
    {fl : Frame.Flow} (h : Frame.Flow.of d mode facts = .ok fl) {k : Nat} (hk : k < d.insns.size)
    {j : Nat} {sc : R.Scope} {a : Nat} (hm : (j, sc) ∈ (Frame.scopesAt d)[k]!)
    (hkind : sc.kind = .escape a) {i : Nat}
    (h1 : (Frame.range d.frameSize sc.frameOffset sc.size).1 ≤ i)
    (h2 : i < (Frame.range d.frameSize sc.frameOffset sc.size).2) :
    (fl.escRead[k]!).testBit i = true := by
  unfold Frame.Flow.of at h
  simp only [bind, Except.bind] at h
  split at h
  · cases h
  · rename_i rows hr
    simp only [pure, Except.pure, Except.ok.injEq] at h
    subst h
    obtain ⟨r, hrow, hr2⟩ := mapM_except_ok _ _ rows hr k (by simpa using hk)
    have hpt : (((rows.map Frame.Flow.Row.escRead).toArray)[k]!) = r.escRead := by
      simp [Array.getElem!_eq_getD, Array.getD_eq_getD_getElem?, hr2]
    show (((rows.map Frame.Flow.Row.escRead).toArray)[k]!).testBit i = true
    rw [hpt]
    simp only [List.getElem_range] at hrow
    unfold Frame.Flow.row at hrow
    simp only [bind, Except.bind] at hrow
    split at hrow
    · cases hrow
    · simp only [pure, Except.pure, Except.ok.injEq] at hrow
      subst hrow
      simp only [Frame.Flow.rowOf]
      rw [testBit_rangesBits]
      refine List.any_eq_true.2 ⟨Frame.range d.frameSize sc.frameOffset sc.size, ?_, by simp [h1, h2]⟩
      exact List.mem_filterMap.2 ⟨(j, sc), hm, by simp [hkind]⟩

/-- A byte an `Escape` scope before `k` copies is live into `k` (its range is in `gen`, and an
`End` doesn't take what `k` reads out of `liveIn`). -/
theorem not_dead_of_escape (C : Cert S) {k : Nat} (hk : k < S.c.d.insns.size) {sc : R.Scope}
    (hsc : sc ∈ S.c.scopesAt k) {a : Nat} (hkind : sc.kind = .escape a) {o : Int}
    (h1 : sc.frameOffset.toInt ≤ o) (h2 : o < sc.frameOffset.toInt + sc.size)
    (hdead : Dead S C k o) : False := by
  obtain ⟨⟨hf1, hf2⟩, hbit⟩ := hdead
  unfold R.Code.scopesAt at hsc
  obtain ⟨x, hx, rfl⟩ := List.mem_map.1 hsc
  obtain ⟨hxm, hxk⟩ := List.mem_filter.1 hx
  obtain ⟨j, hj⟩ := List.mem_iff_getElem?.1 hxm
  rw [Array.getElem?_toList] at hj
  have hxk' : x.1 = k := by simpa using hxk
  have hj' : S.c.d.scopes[j]? = some (k, x.2) := by rw [hj, ← hxk']
  have hmem := frame_scopesAt_mem hj' hk
  have hop := flowOf_operand_escape C.hfl hk hmem hkind (i := bit S o)
    (by simp only [Frame.range, bit]; omega) (by simp only [Frame.range, bit]; omega)
  have hg : (C.fl.gen k).testBit (bit S o) = true := by
    unfold Frame.Flow.gen Frame.Flow.direct
    rw [testBit_rangesBits] at hop
    rw [Nat.testBit_or, testBit_rangesBits, List.any_append]
    simp [hop]
  have hsz : k < C.fl.succ.size := by rw [flowOf_succ C.hfl, flow_succ_size]; exact hk
  have hesc := flowOf_escRead_escape C.hfl hk hmem hkind (i := bit S o)
    (by simp only [Frame.range, bit]; omega) (by simp only [Frame.range, bit]; omega)
  have := live_esc C.hlive hsz hg hesc
  rw [hbit] at this
  cases this

/-! ### Scopes against the shadow (T3c) -/

theorem eraseSt_idem (P : Int → Prop) (st : OpSem.State) : eraseSt P (eraseSt P st) = eraseSt P st := by
  unfold eraseSt
  congr 1
  funext o
  by_cases h : P o <;> simp [h]

theorem getD_replicate_uninit (n i : Nat) :
    (List.replicate n AbstractByte.uninit).getD i .uninit = .uninit := by
  rw [List.getD_eq_getElem?_getD, List.getElem?_replicate]
  split <;> rfl

/-- What the scopes keep of the bytes at `P`: private, and `Uninit` if an `Escape` before `pc`
copies it (`InEsc`), or `Uninit` (wherever stored). -/
def KInv (P InEsc : Int → Prop) (st : OpSem.State) : Prop :=
  ∀ o, P o → (st.escapedAt o = none ∧ (InEsc o → st.frame o = .uninit)) ∨
    st.byteAt o = .ok .uninit

theorem byteAt_erase_of {P InEsc : Int → Prop} {st : OpSem.State} (hK : KInv P InEsc st)
    {o : Int} (hio : InEsc o) : (eraseSt P st).byteAt o = st.byteAt o := by
  by_cases hp : P o
  · cases he : st.escapedAt o with
    | some e =>
      have he' : (eraseSt P st).escapedAt o = some e := he
      simp only [OpSem.State.byteAt, he, he']
      all_goals rfl
    | none =>
      have he' : (eraseSt P st).escapedAt o = none := he
      have hf : st.frame o = .uninit := by
        rcases hK o hp with ⟨-, hf⟩ | hb
        · exact hf hio
        · simp only [OpSem.State.byteAt, he] at hb
          exact Except.ok.inj hb
      simp only [OpSem.State.byteAt, he, he', hf]
      simp only [eraseSt, hp, ↓reduceIte, if_true]
      all_goals rfl
  · exact Ryo.Proofs.Scope.byteAt_congr rfl (by simp [eraseSt, hp]) (fun _ _ => rfl)

theorem readFrame_erase {P InEsc : Int → Prop} {st : OpSem.State} (hK : KInv P InEsc st)
    {off : Int} {n : Nat} (hin : ∀ o, off ≤ o → o < off + n → InEsc o) :
    (eraseSt P st).readFrame off n = st.readFrame off n := by
  unfold OpSem.State.readFrame
  apply OpSem.mapM_congr
  intro i hi
  simp only [List.mem_range] at hi
  exact byteAt_erase_of hK (hin _ (by omega) (by omega))

/-- `Escape` from the shadow is `Escape` from `u`, erased (the bytes it copies agree). -/
theorem escape_erase {u : R.RState} {P : Int → Prop} {off : Int} {size align : Nat}
    (hr : (eraseSt P u.st).readFrame off size = u.st.readFrame off size) {v' : R.RState}
    (h : R.escape (erase u P) off size align = .ok v') :
    ∃ u', R.escape u off size align = .ok u' ∧ v' = erase u' P := by
  unfold R.escape at h ⊢
  simp only [erase, eraseSt] at h hr ⊢
  by_cases hA : (u.st.escaped.any fun e => decide (e.off ≤ off ∧ off + ↑size ≤ e.off + ↑e.size)) = true
  · simp only [hA, ↓reduceIte] at h ⊢
    cases h
    exact ⟨u, rfl, rfl⟩
  simp only [hA, ↓reduceIte, Bool.false_eq_true] at h ⊢
  by_cases hB : (u.st.escaped.any fun e => decide (e.off < off + ↑size ∧ off < e.off + ↑e.size)) = true
  · simp only [hB, ↓reduceIte] at h
    cases h
  simp only [hB, ↓reduceIte, Bool.false_eq_true] at h ⊢
  cases hfa : R.frameAddr u.fp off with
  | error e => rw [hfa] at h; cases h
  | ok addr =>
    rw [hfa] at h
    simp only [bind, Except.bind] at h ⊢
    by_cases hal : (!(Align.ofBytes align).isAligned addr) = true
    · simp only [hal, ↓reduceIte] at h
      cases h
    simp only [hal, ↓reduceIte, Bool.false_eq_true] at h ⊢
    by_cases hC : (u.st.mem.allocs.any fun a => a.live && a.overlaps addr size) = true
    · simp only [hC, ↓reduceIte] at h
      cases h
    simp only [hC, ↓reduceIte, Bool.false_eq_true] at h ⊢
    rw [hr] at h
    cases hrf : u.st.readFrame off size with
    | error e => rw [hrf] at h; cases h
    | ok bytes =>
      rw [hrf] at h
      cases h
      exact ⟨_, rfl, rfl⟩

/-- A write of `Uninit` from the shadow is the write from the state, erased. -/
theorem writeFrame_erase {st st' : OpSem.State} {P : Int → Prop} {off : Int} {n : Nat}
    (h : (eraseSt P st).writeFrame off (List.replicate n .uninit) = .ok st') :
    ∃ st2, st.writeFrame off (List.replicate n .uninit) = .ok st2 ∧ st' = eraseSt P st2 := by
  unfold OpSem.State.writeFrame at h ⊢
  have hW : (eraseSt P st).writeEscaped off (List.replicate n .uninit) =
      st.writeEscaped off (List.replicate n .uninit) := rfl
  rw [hW] at h
  cases hm : st.writeEscaped off (List.replicate n .uninit) with
  | error e => rw [hm] at h; cases h
  | ok m =>
    rw [hm] at h
    cases h
    refine ⟨_, rfl, ?_⟩
    unfold eraseSt
    congr 1
    funext o
    simp only [OpSem.State.privateIn, OpSem.State.escapedAt]
    by_cases hp : P o
    · simp only [hp, ↓reduceIte]
      split
      · exact getD_replicate_uninit _ _
      · rfl
    · simp only [hp, ↓reduceIte]
      all_goals rfl

/-- `End` from the shadow is `End` from `u`, erased. -/
theorem storageEnd_erase {u : R.RState} {P : Int → Prop} {off : Int} {size : Nat} {v' : R.RState}
    (h : R.storageEnd (erase u P) off size = .ok v') :
    ∃ u', R.storageEnd u off size = .ok u' ∧ v' = erase u' P := by
  obtain ⟨st', hw, rfl⟩ := Ryo.Proofs.Scope.storageEnd_ok h
  obtain ⟨st2, hw2, rfl⟩ := writeFrame_erase (P := P)
    (st := ({ u.st with
      mem := R.freeObjs u.st.mem
        (u.st.escaped.filter fun e => decide (off ≤ e.off ∧ e.off + e.size ≤ off + size)),
      escaped := u.st.escaped.filter
        (not ∘ fun e => decide (off ≤ e.off ∧ e.off + e.size ≤ off + size)) } : OpSem.State)) hw
  refine ⟨{ u with st := st2 }, ?_, rfl⟩
  unfold R.storageEnd
  simp only [List.partition_eq_filter_filter, bind, Except.bind]
  split
  · rename_i e he
    exact absurd (hw2.symm.trans he) (by intro hc; cases hc)
  · rename_i st3 he
    have h3 := hw2.symm.trans he
    cases h3
    rfl

theorem writeFrame_parts {st st' : OpSem.State} {off : Int} {bs : List AbstractByte}
    (h : st.writeFrame off bs = .ok st') :
    ∃ m', st.writeEscaped off bs = .ok m' ∧ st'.mem = m' ∧ st'.escaped = st.escaped ∧
      ∀ o, st'.frame o =
        if st.privateIn off bs.length o then bs.getD (o - off).toNat .uninit else st.frame o := by
  unfold OpSem.State.writeFrame at h
  cases hm : st.writeEscaped off bs with
  | error e => simp [hm, bind, Except.bind] at h
  | ok m' =>
    simp only [hm, bind, Except.bind, pure, Except.pure, Except.ok.injEq] at h
    subst h
    exact ⟨m', rfl, rfl, rfl, fun _ => rfl⟩

theorem kInv_escape {P InEsc : Int → Prop} {u u' : R.RState} {off : Int} {size align : Nat}
    (hw : Ryo.Proofs.Scope.EscWF u.st) (h : R.escape u off size align = .ok u')
    (hin : ∀ o, off ≤ o → o < off + size → InEsc o) (hK : KInv P InEsc u.st) :
    KInv P InEsc u'.st := by
  rcases Ryo.Proofs.Scope.escape_ok h with rfl | ⟨bytes, a, hdis, -, -, hdata, hlive, hread, rfl⟩
  · exact hK
  obtain ⟨hlen, hall⟩ := Ryo.Proofs.Inline.mapM_ok hread
  simp only [List.length_range] at hlen
  have hget : ∀ e ∈ u.st.escaped,
      ({ allocs := u.st.mem.allocs.push a } : Memory).get? e.id = u.st.mem.get? e.id := by
    intro e he
    have := hw.idLt e he
    simp only [Memory.get?, Array.getElem?_push, Nat.ne_of_lt this, ↓reduceIte]
  have hgetn : ({ allocs := u.st.mem.allocs.push a } : Memory).get? u.st.mem.allocs.size = some a := by
    simp [Memory.get?]
  intro o ho
  dsimp only
  by_cases hio : off ≤ o ∧ o < off + size
  · have hnone : u.st.escapedAt o = none := by
      cases hf : u.st.escapedAt o with
      | none => rfl
      | some e =>
        obtain ⟨he, h1, h2⟩ := Ryo.Proofs.Inline.escapedAt_some hf
        exact (hdis e he ⟨by omega, by omega⟩).elim
    have hb0 : u.st.byteAt o = .ok .uninit := by
      rcases hK o ho with ⟨-, hf⟩ | hb
      · simp only [OpSem.State.byteAt, hnone, hf (hin o hio.1 hio.2)]
        all_goals rfl
      · exact hb
    have hk : (o - off).toNat < bytes.length := by omega
    have hb' := hall (o - off).toNat (by simp; omega) hk
    simp only [List.getElem_range, show off + ((o - off).toNat : Int) = o by omega] at hb'
    rw [hb0] at hb'
    have hesc : ({ u.st with
        mem := ({ allocs := u.st.mem.allocs.push a } : Memory),
        escaped := u.st.escaped ++ [({ off := off, size := size, id := u.st.mem.allocs.size } : OpSem.EscapedObj)],
        exposed := u.st.exposed ++ [u.st.mem.allocs.size] } : OpSem.State).escapedAt o =
          some { off := off, size := size, id := u.st.mem.allocs.size } := by
      simp only [OpSem.State.escapedAt, List.find?_append] at hnone ⊢
      rw [hnone]
      simp [hio]
    right
    unfold OpSem.State.byteAt
    rw [hesc]
    simp only
    rw [hgetn]
    simp only [hlive, Bool.not_true, Bool.false_eq_true, ↓reduceIte, hdata,
      List.getElem?_toArray, List.getElem?_eq_getElem hk]
    rw [← Except.ok.inj hb'] <;> rfl
  · have hea : ({ u.st with
        mem := ({ allocs := u.st.mem.allocs.push a } : Memory),
        escaped := u.st.escaped ++ [({ off := off, size := size, id := u.st.mem.allocs.size } : OpSem.EscapedObj)],
        exposed := u.st.exposed ++ [u.st.mem.allocs.size] } : OpSem.State).escapedAt o =
          u.st.escapedAt o := by
      simp only [OpSem.State.escapedAt, List.find?_append]
      cases hf : u.st.escaped.find? (fun e => decide (e.off ≤ o ∧ o < e.off + e.size)) with
      | some e => rfl
      | none => simp [hio]
    rcases hK o ho with ⟨hn, hf⟩ | hb
    · exact .inl ⟨hea.trans hn, hf⟩
    · right
      rw [← hb]
      exact Ryo.Proofs.Scope.byteAt_congr hea rfl
        (fun e he => hget e (Ryo.Proofs.Inline.escapedAt_some he).1)

theorem kInv_storageEnd {P InEsc : Int → Prop} {u u' : R.RState} {off : Int} {size : Nat}
    (hw : Ryo.Proofs.Scope.EscWF u.st) (h : R.storageEnd u off size = .ok u')
    (hK : KInv P InEsc u.st) : KInv P InEsc u'.st := by
  obtain ⟨st', hw', rfl⟩ := Ryo.Proofs.Scope.storageEnd_ok h
  obtain ⟨hlt, hinj, -, hdj⟩ := hw
  generalize hcov : (fun e : OpSem.EscapedObj => decide (off ≤ e.off ∧ e.off + e.size ≤ off + size)) = cov at hw'
  generalize hst1 : ({ u.st with
        mem := R.freeObjs u.st.mem (u.st.escaped.filter cov),
        escaped := u.st.escaped.filter (not ∘ cov) } : OpSem.State) = st1 at hw'
  have hkept : ∀ e ∈ st1.escaped, e ∈ u.st.escaped ∧ cov e = false := by
    intro e he; subst hst1
    simpa using (List.mem_filter.1 he)
  have hm1 : ∀ e ∈ st1.escaped, st1.mem.get? e.id = u.st.mem.get? e.id := by
    intro e he
    obtain ⟨he0, hc⟩ := hkept e he
    subst hst1
    apply Ryo.Proofs.Scope.freeObjs_get
    intro e' he' hid
    obtain ⟨he0', hc'⟩ := List.mem_filter.1 he'
    rw [hinj e' he0' e he0 hid] at hc'
    rw [hc] at hc'; cases hc'
  have hsz1 : st1.mem.allocs.size = u.st.mem.allocs.size := by
    subst hst1; exact Ryo.Proofs.Scope.freeObjs_size _ _
  have hea : ∀ o, ¬ (off ≤ o ∧ o < off + size) → st1.escapedAt o = u.st.escapedAt o := by
    intro o hout
    subst hst1
    unfold OpSem.State.escapedAt
    show (List.filter (not ∘ cov) u.st.escaped).find? _ = u.st.escaped.find? _
    cases hf : u.st.escaped.find? (fun e => decide (e.off ≤ o ∧ o < e.off + e.size)) with
    | none => exact Ryo.Proofs.Scope.find?_filter_of_none hf
    | some e =>
      apply Ryo.Proofs.Scope.find?_filter_of_some hf
      obtain ⟨he, h1, h2⟩ := Ryo.Proofs.Inline.escapedAt_some (st := u.st) (o := o) hf
      subst hcov
      simp only [Function.comp, Bool.not_eq_eq_eq_not, Bool.not_true, decide_eq_false_iff_not]
      omega
  have hfr1 : ∀ o, st1.frame o = u.st.frame o := fun o => by subst hst1; rfl
  obtain ⟨m', hm, hmem, hesc', hfrm⟩ := writeFrame_parts hw'
  have hesc := Ryo.Proofs.Inline.writeEscaped_spec hm
  have heaF : ∀ o, st'.escapedAt o = st1.escapedAt o := fun o => by
    unfold OpSem.State.escapedAt; rw [hesc']
  have hget1 : ∀ e ∈ st1.escaped, ∃ a', st'.mem.get? e.id = some a' := fun e he => by
    rw [hmem]
    have : e.id < m'.allocs.size := by rw [hesc.1, hsz1]; exact hlt e (hkept e he).1
    simp only [Memory.get?]
    exact ⟨_, Array.getElem?_eq_getElem this⟩
  intro o ho
  show (st'.escapedAt o = none ∧ (InEsc o → st'.frame o = .uninit)) ∨ st'.byteAt o = .ok .uninit
  by_cases hin : off ≤ o ∧ o < off + size
  · cases hf : st1.escapedAt o with
    | none =>
      left
      refine ⟨(heaF o).trans hf, fun _ => ?_⟩
      rw [hfrm o]
      simp only [OpSem.State.privateIn, List.length_replicate, hin, hf, Option.isNone_none,
        and_self, decide_true, Bool.and_self, ↓reduceIte]
      exact getD_replicate_uninit _ _
    | some e =>
      right
      obtain ⟨he1, h1, h2⟩ := Ryo.Proofs.Inline.escapedAt_some hf
      obtain ⟨he0, -⟩ := hkept e he1
      have hu : u.st.escapedAt o = some e := ds_escapedAt_of_mem hdj he0 h1 h2
      have hb0 : u.st.byteAt o = .ok .uninit := by
        rcases hK o ho with ⟨hn, -⟩ | hb
        · rw [hu] at hn; cases hn
        · exact hb
      rcases ds_byteAt_ok hb0 with ⟨hn, -⟩ | ⟨e', a, he', ha, hl, hd⟩
      · rw [hu] at hn; cases hn
      rw [hu] at he'
      cases he'
      obtain ⟨a', ha'⟩ := hget1 e he1
      have ha'm : m'.get? e.id = some a' := by rw [← hmem]; exact ha'
      obtain ⟨a1, ha1, hae, -, hj⟩ := hesc.2 e.id a' ha'm
      rw [hm1 e he1, ha] at ha1
      cases ha1
      have hk : (o - off).toNat < size := by omega
      have hhit : Ryo.Proofs.Inline.Hits st1 off (.uninit, (o - off).toNat) e.id (o - e.off).toNat :=
        ⟨e, by rw [show off + ((o - off).toNat : Int) = o by omega]; exact hf, rfl,
          by rw [show off + ((o - off).toNat : Int) = o by omega]⟩
      have hjl : (o - e.off).toNat < a.data.size := (Array.getElem?_eq_some_iff.1 hd).1
      obtain ⟨q, hq, -, hv⟩ := (hj _).2
        ⟨_, List.mem_zipIdx_iff_getElem?.2 (by simp [hk]), hhit⟩ hjl
      obtain ⟨hqk, hq1⟩ := Ryo.Proofs.Inline.mem_zipIdx hq
      have hq1' : q.1 = .uninit := by rw [hq1]; simp
      have hl' : a'.live = true := by rw [hae]; exact hl
      exact ds_byteAt_of_some ((heaF o).trans hf) ha' hl' (by rw [hv, hq1'])
  · have hea1 := hea o hin
    have hfo : st'.frame o = u.st.frame o := by
      rw [hfrm o]
      simp only [OpSem.State.privateIn, List.length_replicate, hin, decide_false,
        Bool.false_and, Bool.false_eq_true, ↓reduceIte]
      exact hfr1 o
    cases hu : u.st.escapedAt o with
    | none =>
      have hn' : st'.escapedAt o = none := (heaF o).trans (hea1.trans hu)
      rcases hK o ho with ⟨-, hf⟩ | hb
      · exact .inl ⟨hn', fun hi => hfo.trans (hf hi)⟩
      · right
        rw [ds_byteAt_of_none hn', hfo]
        rw [ds_byteAt_of_none hu] at hb
        exact hb
    | some e =>
      rcases hK o ho with ⟨hn, -⟩ | hb
      · rw [hu] at hn; cases hn
      right
      rcases ds_byteAt_ok hb with ⟨hn, -⟩ | ⟨e', a, he', ha, hl, hd⟩
      · rw [hu] at hn; cases hn
      rw [hu] at he'
      cases he'
      obtain ⟨he0, h1, h2⟩ := Ryo.Proofs.Inline.escapedAt_some hu
      have he1 : e ∈ st1.escaped := (Ryo.Proofs.Inline.escapedAt_some (hea1.trans hu)).1
      obtain ⟨a', ha'⟩ := hget1 e he1
      have ha'm : m'.get? e.id = some a' := by rw [← hmem]; exact ha'
      obtain ⟨a1, ha1, hae, -, hj⟩ := hesc.2 e.id a' ha'm
      rw [hm1 e he1, ha] at ha1
      cases ha1
      have hnh : ∀ p ∈ (List.replicate size AbstractByte.uninit).zipIdx,
          ¬ Ryo.Proofs.Inline.Hits st1 off p e.id (o - e.off).toNat := by
        rintro q hq ⟨e', he', hid', hj'⟩
        obtain ⟨hqk, -⟩ := Ryo.Proofs.Inline.mem_zipIdx hq
        simp only [List.length_replicate] at hqk
        obtain ⟨he'0, h1', h2'⟩ := Ryo.Proofs.Inline.escapedAt_some he'
        have := hinj e' (hkept e' he'0).1 e he0 hid'
        subst this
        omega
      have hdat := (hj _).1 hnh
      have hl' : a'.live = true := by rw [hae]; exact hl
      exact ds_byteAt_of_some ((heaF o).trans (hea1.trans hu)) ha' hl' (by rw [hdat]; exact hd)

theorem applyScope_erase {P InEsc : Int → Prop} {x : X86.State} {u v' : R.RState} {sc : R.Scope}
    (hr : Ryo.Proofs.Scope.RRel u x) (hK : KInv P InEsc u.st)
    (hesc : ∀ a, sc.kind = .escape a → ∀ o, sc.frameOffset.toInt ≤ o →
      o < sc.frameOffset.toInt + sc.size → InEsc o)
    (h : R.applyScope (erase u P) sc = .ok v') :
    ∃ u', R.applyScope u sc = .ok u' ∧ v' = erase u' P ∧ KInv P InEsc u'.st := by
  unfold R.applyScope at h ⊢
  split at h
  · rename_i a hk
    try simp only [hk]
    have hin := hesc a hk
    obtain ⟨u', hu', rfl⟩ := escape_erase (readFrame_erase hK hin) h
    exact ⟨u', hu', rfl, kInv_escape hr.wf hu' hin hK⟩
  · rename_i hk
    try simp only [hk]
    obtain ⟨u', hu', rfl⟩ := storageEnd_erase h
    exact ⟨u', hu', rfl, kInv_storageEnd hr.wf hu' hK⟩
  · rename_i hk
    try simp only [hk]
    cases h
    exact ⟨u, rfl, rfl, hK⟩

theorem scopes_erase_aux (P InEsc : Int → Prop) (x : X86.State) :
    ∀ (l : List R.Scope) {u v1 : R.RState},
      (∀ sc ∈ l, ∀ a, sc.kind = .escape a → ∀ o, sc.frameOffset.toInt ≤ o →
        o < sc.frameOffset.toInt + sc.size → InEsc o) →
      Ryo.Proofs.Scope.RRel u x → KInv P InEsc u.st →
      l.foldlM R.applyScope (erase u P) = .ok v1 →
      ∃ u1, l.foldlM R.applyScope u = .ok u1 ∧ v1 = erase u1 P ∧ KInv P InEsc u1.st
  | [], u, v1, _, _, hK, h => by cases h; exact ⟨u, rfl, rfl, hK⟩
  | sc :: l, u, v1, hl, hr, hK, h => by
    simp only [List.foldlM_cons, bind, Except.bind] at h ⊢
    cases h1 : R.applyScope (erase u P) sc with
    | error e => simp [h1] at h
    | ok v2 =>
      simp only [h1] at h
      obtain ⟨u2, hu2, rfl, hK2⟩ :=
        applyScope_erase hr hK (hl sc (List.mem_cons_self ..)) h1
      rw [hu2]
      simp only
      exact scopes_erase_aux P InEsc x l (fun sc' hs => hl sc' (List.mem_cons_of_mem _ hs))
        (Ryo.Proofs.Scope.rrel_applyScope hr hu2) hK2 h

/-- T3c: the scopes before `k` commute with `erase` (observationally): `Escape` copies the
`Uninit` bytes into the allocation, `End` writes `Uninit`, `Lend` changes nothing. -/
theorem scopes_erase (C : Cert S) {s t1 : R.RState} {P : Int → Prop} (h : StepPre S C s P)
    (hsc : (S.c.scopesAt s.pc).foldlM R.applyScope (erase s P) = .ok t1) :
    ∃ s1, (S.c.scopesAt s.pc).foldlM R.applyScope s = .ok s1 ∧ RAgree P s1 t1 ∧
      ∀ o, P o → t1.st.byteAt o = .ok .uninit := by
  obtain ⟨xh, hfr⟩ := h.frame
  have hr : Ryo.Proofs.Scope.RRel s (S.virt xh) := hfr.1.rrel
  let InEsc : Int → Prop := fun o => ∃ sc ∈ S.c.scopesAt s.pc, ∃ a, sc.kind = .escape a ∧
    sc.frameOffset.toInt ≤ o ∧ o < sc.frameOffset.toInt + sc.size
  have hK0 : KInv P InEsc s.st := by
    intro o ho
    obtain ⟨-, -, hpriv, hd⟩ := h.patch o ho
    refine .inl ⟨hpriv, fun hio => ?_⟩
    rcases hd with hdead | ⟨hb, -⟩
    · obtain ⟨sc, hsc, a, hk, h1, h2⟩ := hio
      exact (not_dead_of_escape C h.lt hsc hk h1 h2 hdead).elim
    · simp only [OpSem.State.byteAt, hpriv] at hb
      exact Except.ok.inj hb
  obtain ⟨s1, hs1, rfl, hK1⟩ := scopes_erase_aux P InEsc (S.virt xh) _
    (fun sc hsc a hk o h1 h2 => ⟨sc, hsc, a, hk, h1, h2⟩) hr hK0 hsc
  refine ⟨s1, hs1, ⟨rfl, rfl, rfl, ?_⟩, fun o ho => ?_⟩
  · show StEq (eraseSt P s1.st) (eraseSt P (eraseSt P s1.st))
    rw [eraseSt_idem]
    exact ⟨rfl, rfl, rfl, rfl, rfl, fun _ _ => rfl⟩
  · show (eraseSt P s1.st).byteAt o = .ok .uninit
    have hnone : s1.st.escapedAt o = none → (eraseSt P s1.st).byteAt o = .ok .uninit := by
      intro hn
      have hn' : (eraseSt P s1.st).escapedAt o = none := hn
      simp only [OpSem.State.byteAt, hn']
      simp only [eraseSt, ho, ↓reduceIte, if_true]
      all_goals rfl
    rcases hK1 o ho with ⟨hn, -⟩ | hb
    · exact hnone hn
    · cases he : s1.st.escapedAt o with
      | none => exact hnone he
      | some e =>
        have he' : (eraseSt P s1.st).escapedAt o = some e := he
        rw [← hb]
        simp only [OpSem.State.byteAt, he, he']
        all_goals rfl

/-! ### Flow rows and successors (T3c) -/

theorem forIn'_push_prop {β : Type} {R : Nat → β → Prop} : ∀ (l : List Nat) (init : Array β)
    (f : (a : Nat) → a ∈ l → Array β → Id (ForInStep (Array β))),
    (∀ a h b, ∃ x, f a h b = pure (ForInStep.yield (b.push x)) ∧ R a x) →
    (∀ j, j < init.size → (forIn' l init f).run[j]? = init[j]?) ∧
      ∀ i (hi : i < l.length), ∃ x, (forIn' l init f).run[init.size + i]? = some x ∧ R l[i] x
  | [], init, f, _ => ⟨fun j _ => by simp, fun i hi => by simp at hi⟩
  | a :: l, init, f, hf => by
    obtain ⟨x, hx, hRx⟩ := hf a (List.mem_cons_self ..) init
    have ih := forIn'_push_prop (R := R) l (init.push x)
      (fun a h b => f a (List.mem_cons_of_mem _ h) b) (fun a h b => hf a _ b)
    have hrun : (forIn' (a :: l) init f).run =
        (forIn' l (init.push x) (fun a h b => f a (List.mem_cons_of_mem _ h) b)).run := by
      simp only [List.forIn'_cons, hx, pure_bind]
      all_goals rfl
    refine ⟨fun j hj => ?_, fun i hi => ?_⟩
    · rw [hrun, ih.1 j (by simp only [Array.size_push]; omega), Array.getElem?_push,
        if_neg (by omega)]
    · rw [hrun]
      cases i with
      | zero =>
        refine ⟨x, ?_, hRx⟩
        rw [Nat.add_zero, ih.1 init.size (by simp only [Array.size_push]; omega),
          Array.getElem?_push, if_pos rfl]
      | succ i =>
        obtain ⟨y, hy, hRy⟩ := ih.2 i (by simp at hi; omega)
        refine ⟨y, ?_, hRy⟩
        rw [show init.size + (i + 1) = (init.push x).size + i by simp only [Array.size_push]; omega]
        exact hy

theorem forIn'_push_mem {R : Nat → List Nat → Prop} {n : Nat}
    (f : (a : Nat) → a ∈ List.range' 0 n 1 → Array (List Nat) → Id (ForInStep (Array (List Nat))))
    (hf : ∀ a h b, ∃ x, f a h b = pure (ForInStep.yield (b.push x)) ∧ R a x)
    {k : Nat} (hk : k < n) {y : Nat} (hy : ∀ x, R k x → y ∈ x) :
    y ∈ (forIn' (List.range' 0 n 1) #[] f).run[k]! := by
  obtain ⟨x, hx, hR⟩ := (forIn'_push_prop (R := R) _ #[] f hf).2 k (by simpa using hk)
  simp only [Array.size_empty, Nat.zero_add] at hx
  simp only [List.getElem_range', Nat.zero_add, Nat.one_mul] at hR
  rw [Array.getElem!_eq_getD, Array.getD_eq_getD_getElem?, hx, Option.getD_some]
  exact hy x hR

/-- A target operand of instruction `k`, in range, is one of `flow`'s successors of `k`. -/
theorem flow_succ_target {d : Decoded} {k : Nat} {op : Reduced.Opcode} {ops : List (Opnd Nat)}
    (hi : d.insns[k]? = some (.native op ops)) {t : Nat} (ht : Opnd.target t ∈ ops)
    (htn : t < d.insns.size) : t ∈ (Frame.flow d).1[k]! := by
  have hk : k < d.insns.size := by
    rcases Nat.lt_or_ge k d.insns.size with h | h
    · exact h
    · rw [Array.getElem?_eq_none h] at hi; cases hi
  unfold Frame.flow
  simp only [Id.run_bind, Id.run_pure, Std.Legacy.Range.forIn'_eq_forIn'_range',
    Std.Legacy.Range.size]
  refine forIn'_push_mem (R := fun a x => ∀ op ops, d.insns[a]? = some (.native op ops) →
    ∀ t, Opnd.target t ∈ ops → t < d.insns.size → t ∈ x) _ ?_ (by simpa using hk)
    (fun x hR => hR op ops hi t ht htn)
  intro a h b
  refine ⟨_, rfl, ?_⟩
  intro op' ops' hop t' ht' htn'
  have hd : ∀ hh : a < d.insns.size, d.insns[a]'hh = .native op' ops' := fun hh => by
    rw [Array.getElem?_eq_getElem hh] at hop
    exact Option.some.inj hop
  simp only [hd]
  exact List.mem_filter.2 ⟨List.mem_append_right _
    (List.mem_flatMap.2 ⟨_, ht', by simp [Opnd.targetsOf]⟩), by simpa using htn'⟩

/-- Instruction `k`'s row of `Flow.of` (its `kill`, `uninit`, `ends`). -/
theorem flowOf_row {d : Decoded} {mode : Ryo.Obj.Mode} {facts : Frame.Facts} {fl : Frame.Flow}
    (h : Frame.Flow.of d mode facts = .ok fl) {k : Nat} (hk : k < d.insns.size) :
    ∃ e, Frame.effects d.insns[k]! (d.items[k]?.getD []) mode
        (Frame.Flow.lendsOf (Frame.scopesAt d) k) (facts.islandTemplate k) = .ok e ∧
      ∃ r : Frame.Flow.Row, (∃ eb, Frame.Flow.rowOf d facts (Frame.scopesAt d) k e eb = r) ∧
        fl.kill[k]! = r.kill ∧ fl.uninit[k]! = r.uninit ∧ fl.ends[k]! = r.ends := by
  unfold Frame.Flow.of at h
  simp only [bind, Except.bind] at h
  split at h
  · cases h
  · rename_i rows hr
    simp only [pure, Except.pure, Except.ok.injEq] at h
    subst h
    obtain ⟨r, hrow, hr2⟩ := mapM_except_ok _ _ rows hr k (by simpa using hk)
    simp only [List.getElem_range] at hrow
    unfold Frame.Flow.row at hrow
    simp only [bind, Except.bind] at hrow
    split at hrow
    · cases hrow
    · rename_i e he
      simp only [pure, Except.pure, Except.ok.injEq] at hrow
      refine ⟨e, he, r, ⟨_, hrow⟩, ?_, ?_, ?_⟩ <;>
        simp [Array.getElem!_eq_getD, Array.getD_eq_getD_getElem?, hr2]

set_option maxRecDepth 100000 in
theorem reduced_shapeTable : (List.range Reduced.toFullTable.size).all (fun i =>
    match Reduced.toFullTable[i]! with
    | some f => (Reduced.Opcode.info ⟨i.toUInt16⟩).shape == f.info.shape
    | none => true) = true := by
  decide +kernel

/-- A reduced opcode has its full opcode's shape. -/
theorem reduced_shape {op : Reduced.Opcode} {f : Full.Opcode} (h : op.full = some f) :
    op.info.shape = f.info.shape := by
  unfold Reduced.Opcode.full at h
  have hlt : op.val.toNat < Reduced.toFullTable.size := Classical.byContradiction fun hn => by
    rw [getElem!_neg Reduced.toFullTable op.val.toNat hn] at h
    cases h
  have := List.all_eq_true.1 reduced_shapeTable op.val.toNat (List.mem_range.2 hlt)
  rw [h] at this
  simp only [beq_iff_eq] at this
  have hop : (⟨op.val.toNat.toUInt16⟩ : Reduced.Opcode) = op := by cases op; simp
  rw [hop] at this
  exact this

theorem forIn_id_const {α σ : Type} (l : List α) (s : σ) (f : α → σ → Id (ForInStep σ))
    (h : ∀ x ∈ l, f x s = pure (ForInStep.yield s)) : forIn l s f = pure s := by
  induction l with
  | nil => rfl
  | cons a l ih =>
    rw [List.forIn_cons, h a (List.mem_cons_self ..), pure_bind]
    exact ih (fun x hx => h x (List.mem_cons_of_mem _ hx))

/-- `jmp`'s frame operands: none. -/
theorem native_jmp_opnds {op : Reduced.Opcode} (hs : op.info.shape = .jmp) (t : Nat) (pe : Bool)
    (lends : List (BitVec 32 × Nat)) (tmpl : Option String) :
    (Frame.native op [.target t] pe lends tmpl).opnds = [] := by
  unfold Frame.native
  simp only [hs]
  rw [forIn_id_const]
  · rfl
  · intro x hx
    obtain ⟨o, v⟩ := x
    have hv : v = .target t := by
      have := (List.of_mem_zip hx).2
      simpa using this
    subst hv
    generalize o.kind = kd
    cases kd <;> rfl

/-- At a non-inline `jmp`, `Flow.of` kills nothing, makes nothing `Uninit`, and its `ends` are the
`End` scopes before it. -/
theorem flowOf_jmp_row {d : Decoded} {mode : Ryo.Obj.Mode} {facts : Frame.Facts} {fl : Frame.Flow}
    (h : Frame.Flow.of d mode facts = .ok fl) {k : Nat} {op : Reduced.Opcode} {t : Nat}
    (hi : d.insns[k]? = some (.native op [.target t])) (hs : op.info.shape = .jmp)
    (hni : (op.full.bind Asm.classOf).isSome = false) :
    fl.kill[k]! = [] ∧ fl.uninit[k]! = [] ∧
      fl.ends[k]! = (Frame.scopesAt d)[k]!.filterMap fun (_, sc) =>
        if sc.kind == .end then some (Frame.range d.frameSize sc.frameOffset sc.size) else none := by
  have hk : k < d.insns.size := by
    rcases Nat.lt_or_ge k d.insns.size with h | h
    · exact h
    · rw [Array.getElem?_eq_none h] at hi; cases hi
  have hik : d.insns[k]! = .native op [.target t] := by
    rw [getElem!_pos d.insns k hk]
    rw [Array.getElem?_eq_getElem hk] at hi
    exact Option.some.inj hi
  obtain ⟨e, he, r, ⟨eb, rfl⟩, hkl, hun, hen⟩ := flowOf_row h hk
  rw [hik] at he
  simp only [Frame.effects, hni, Bool.false_eq_true, ↓reduceIte, pure, Except.pure,
    Except.ok.injEq] at he
  subst he
  have hop := native_jmp_opnds hs t mode.pe (Frame.Flow.lendsOf (Frame.scopesAt d) k)
    (facts.islandTemplate k)
  refine ⟨?_, ?_, ?_⟩
  · rw [hkl]
    simp only [Frame.Flow.rowOf, hop]
    rfl
  · rw [hun]
    simp only [Frame.Flow.rowOf, Frame.Flow.callInfo, hik, hs]
    rfl
  · rw [hen]
    rfl

theorem scopesAt_foldr_of_mem (L : List ((Nat × R.Scope) × Nat)) (A : Array (List (Nat × R.Scope)))
    (f : (Nat × R.Scope) × Nat → Array (List (Nat × R.Scope)) → Array (List (Nat × R.Scope)))
    (hf : ∀ k sc j a, f ((k, sc), j) a = if k < a.size then a.modify k ((j, sc) :: ·) else a)
    (hA : ∀ (k : Nat) (l : List (Nat × R.Scope)), A[k]? = some l → l = []) :
    ∀ (k : Nat) (l : List (Nat × R.Scope)), (L.foldr f A)[k]? = some l →
      ∀ y ∈ l, ((k, y.2), y.1) ∈ L := by
  induction L with
  | nil =>
    intro k l hl y hy
    rw [hA k l hl] at hy
    cases hy
  | cons x L ih =>
    obtain ⟨⟨k', sc⟩, j⟩ := x
    intro k l hl y hy
    rw [List.foldr_cons, hf] at hl
    split at hl
    · rw [Array.getElem?_modify] at hl
      split at hl
      · rename_i heq
        subst heq
        cases hb : (L.foldr f A)[k']? with
        | none => rw [hb] at hl; cases hl
        | some l' =>
          rw [hb] at hl
          simp only [Option.map_some, Option.some.injEq] at hl
          subst hl
          rcases List.mem_cons.1 hy with rfl | hy
          · exact List.mem_cons_self ..
          · exact List.mem_cons_of_mem _ (ih k' l' hb y hy)
      · exact List.mem_cons_of_mem _ (ih k l hl y hy)
    · exact List.mem_cons_of_mem _ (ih k l hl y hy)

/-- An entry of `Frame.scopesAt d`'s row `k` is a scope before `k`. -/
theorem mem_scopesAt_of_frame {d : Decoded} {k j : Nat} {sc : R.Scope}
    (h : (j, sc) ∈ (Frame.scopesAt d)[k]!) (c : R.Code) (hc : c.d = d) : sc ∈ c.scopesAt k := by
  have he : Frame.scopesAt d = d.scopes.toList.zipIdx.foldr
      (fun x a => if x.1.1 < a.size then a.modify x.1.1 ((x.2, x.1.2) :: ·) else a)
      (Array.replicate d.insns.size []) := by
    unfold Frame.scopesAt
    rw [← Array.foldr_toList, Array.toList_zipIdx]
    all_goals rfl
  rw [he] at h
  have hmem := scopesAt_foldr_of_mem d.scopes.toList.zipIdx (Array.replicate d.insns.size [])
    (fun x a => if x.1.1 < a.size then a.modify x.1.1 ((x.2, x.1.2) :: ·) else a)
    (fun _ _ _ _ => rfl)
    (fun k l hl => by
      rw [Array.getElem?_replicate] at hl
      split at hl
      · exact (Option.some.inj hl).symm
      · cases hl)
  cases hl : (d.scopes.toList.zipIdx.foldr
      (fun x a => if x.1.1 < a.size then a.modify x.1.1 ((x.2, x.1.2) :: ·) else a)
      (Array.replicate d.insns.size []))[k]? with
  | none =>
    simp only [Array.getElem!_eq_getD, Array.getD_eq_getD_getElem?, hl, Option.getD_none] at h
    cases h
  | some l =>
    simp only [Array.getElem!_eq_getD, Array.getD_eq_getD_getElem?, hl, Option.getD_some] at h
    have hx := hmem k l hl (j, sc) h
    unfold R.Code.scopesAt
    rw [hc]
    exact List.mem_map.2 ⟨(k, sc), List.mem_filter.2
      ⟨List.mem_iff_getElem?.2 ⟨j, List.mem_zipIdx_iff_getElem?.1 hx⟩, by simp⟩, rfl⟩

/-! ### Bytes an `End` before `pc` covers (T3c) -/

/-- Byte `o` holds no ghost value: escaped, or private and `Uninit`. -/
def NoGhost (st : OpSem.State) (o : Int) : Prop := st.escapedAt o ≠ none ∨ st.frame o = .uninit

theorem noGhost_escape {u u' : R.RState} {off : Int} {size align : Nat}
    (h : R.escape u off size align = .ok u') {o : Int} (hq : NoGhost u.st o) : NoGhost u'.st o := by
  rcases Ryo.Proofs.Scope.escape_ok h with rfl | ⟨_, _, _, _, _, _, _, _, rfl⟩
  · exact hq
  rcases hq with hq | hq
  · left
    dsimp only
    simp only [OpSem.State.escapedAt, List.find?_append] at hq ⊢
    cases hf : u.st.escaped.find? (fun e => decide (e.off ≤ o ∧ o < e.off + e.size)) with
    | none => rw [hf] at hq; exact (hq rfl).elim
    | some e => simp
  · exact .inr hq

theorem noGhost_storageEnd {u u' : R.RState} {off : Int} {size : Nat}
    (h : R.storageEnd u off size = .ok u') {o : Int}
    (hq : NoGhost u.st o ∨ (off ≤ o ∧ o < off + size)) : NoGhost u'.st o := by
  obtain ⟨st', hw, rfl⟩ := Ryo.Proofs.Scope.storageEnd_ok h
  obtain ⟨_, -, -, hesc, hfrm⟩ := writeFrame_parts hw
  show st'.escapedAt o ≠ none ∨ st'.frame o = .uninit
  have hea : st'.escapedAt o = (u.st.escaped.filter (not ∘ fun e =>
      decide (off ≤ e.off ∧ e.off + e.size ≤ off + size))).find?
        (fun e => decide (e.off ≤ o ∧ o < e.off + e.size)) := by
    unfold OpSem.State.escapedAt; rw [hesc]
  by_cases hn : st'.escapedAt o = none
  · right
    rw [hfrm o]
    by_cases hin : off ≤ o ∧ o < off + size
    · have hn' : (List.find? (fun e => decide (e.off ≤ o ∧ o < e.off + e.size))
          (u.st.escaped.filter (not ∘ fun e =>
            decide (off ≤ e.off ∧ e.off + e.size ≤ off + size)))) = none := by rw [← hea]; exact hn
      simp only [OpSem.State.privateIn, OpSem.State.escapedAt, List.length_replicate, hin,
        and_self, decide_true, hn', Option.isNone_none, Bool.and_self, ↓reduceIte]
      exact getD_replicate_uninit _ _
    · simp only [OpSem.State.privateIn, List.length_replicate, hin, decide_false,
        Bool.false_and, Bool.false_eq_true, ↓reduceIte]
      unfold NoGhost at hq
      rcases hq with (hq | hq) | hq
      · exfalso
        apply hq
        unfold OpSem.State.escapedAt
        cases hf : u.st.escaped.find? (fun e => decide (e.off ≤ o ∧ o < e.off + e.size)) with
        | none => rfl
        | some e =>
          exfalso
          obtain ⟨-, h1, h2⟩ := Ryo.Proofs.Inline.escapedAt_some (st := u.st) (o := o) hf
          have := Ryo.Proofs.Scope.find?_filter_of_some (q := (not ∘ fun e =>
            decide (off ≤ e.off ∧ e.off + e.size ≤ off + size))) hf (by
              simp only [Function.comp, Bool.not_eq_eq_eq_not, Bool.not_true,
                decide_eq_false_iff_not]
              omega)
          rw [hea] at hn
          rw [this] at hn
          cases hn
      · exact hq
      · exact (hin hq).elim
  · exact .inl hn

theorem noGhost_foldlM {o : Int} : ∀ (l : List R.Scope) {u u1 : R.RState},
    l.foldlM R.applyScope u = .ok u1 →
    (NoGhost u.st o ∨ ∃ sc ∈ l, sc.kind = .end ∧ sc.frameOffset.toInt ≤ o ∧
      o < sc.frameOffset.toInt + sc.size) → NoGhost u1.st o
  | [], u, u1, h, hq => by
    cases h
    rcases hq with hq | ⟨_, hsc, _⟩
    · exact hq
    · cases hsc
  | sc :: l, u, u1, h, hq => by
    simp only [List.foldlM_cons, bind, Except.bind] at h
    cases h1 : R.applyScope u sc with
    | error e => simp [h1] at h
    | ok u2 =>
      simp only [h1] at h
      by_cases hl : ∃ sc' ∈ l, sc'.kind = .end ∧ sc'.frameOffset.toInt ≤ o ∧
          o < sc'.frameOffset.toInt + sc'.size
      · exact noGhost_foldlM l h (.inr hl)
      · refine noGhost_foldlM l h (.inl ?_)
        have hq' : NoGhost u.st o ∨ (sc.kind = .end ∧ sc.frameOffset.toInt ≤ o ∧
            o < sc.frameOffset.toInt + sc.size) := by
          rcases hq with hq | ⟨sc', hsc', hk⟩
          · exact .inl hq
          · rcases List.mem_cons.1 hsc' with rfl | hsc'
            · exact .inr hk
            · exact (hl ⟨sc', hsc', hk⟩).elim
        unfold R.applyScope at h1
        split at h1
        · rename_i a hk
          rcases hq' with hq' | ⟨hk', -⟩
          · exact noGhost_escape h1 hq'
          · rw [hk] at hk'; cases hk'
        · rcases hq' with hq' | ⟨-, h1', h2'⟩
          · exact noGhost_storageEnd h1 (.inl hq')
          · exact noGhost_storageEnd h1 (.inr ⟨h1', h2'⟩)
        · rename_i hk
          cases h1
          rcases hq' with hq' | ⟨hk', -⟩
          · exact hq'
          · rw [hk] at hk'; cases hk'

/-! ### `jmp` (T3c) -/

theorem step_jmp_ok {c : R.Code} {s : R.RState} {ch : OpSem.Choice} {o : R.Out}
    {op : Reduced.Opcode} {f : Full.Opcode} {t : Nat}
    (hi : c.d.insns[s.pc]? = some (.native op [.target t])) (hf : op.full = some f)
    (hsh : f.info.shape = .jmp) (h : R.step c s ch = .ok o) :
    ∃ s1, (c.scopesAt s.pc).foldlM R.applyScope s = .ok s1 ∧ o = .step { s1 with pc := t } := by
  unfold R.step at h
  simp only [hi, bind, Except.bind] at h
  cases hsc : (c.scopesAt s.pc).foldlM R.applyScope s with
  | error e => simp [hsc] at h
  | ok s1 =>
    simp only [hsc, hf] at h
    rw [hsh] at h
    simp only [pure, Except.pure, Except.ok.injEq] at h
    exact ⟨s1, rfl, h.symm⟩

theorem step_jmp_of {c : R.Code} {s s1 : R.RState} {ch : OpSem.Choice}
    {op : Reduced.Opcode} {f : Full.Opcode} {t : Nat}
    (hi : c.d.insns[s.pc]? = some (.native op [.target t])) (hf : op.full = some f)
    (hsh : f.info.shape = .jmp) (hsc : (c.scopesAt s.pc).foldlM R.applyScope s = .ok s1) :
    R.step c s ch = .ok (.step { s1 with pc := t }) := by
  unfold R.step
  simp only [hi, bind, Except.bind, hsc, hf]
  rw [hsh]
  all_goals rfl

/-- The scopes from the shadow are the scopes from `s`, erased. -/
theorem scopes_erase_eq (C : Cert S) {s t1 : R.RState} {P : Int → Prop} (h : StepPre S C s P)
    (hsc : (S.c.scopesAt s.pc).foldlM R.applyScope (erase s P) = .ok t1) :
    ∃ s1, (S.c.scopesAt s.pc).foldlM R.applyScope s = .ok s1 ∧ t1 = erase s1 P := by
  obtain ⟨xh, hfr⟩ := h.frame
  have hr : Ryo.Proofs.Scope.RRel s (S.virt xh) := hfr.1.rrel
  let InEsc : Int → Prop := fun o => ∃ sc ∈ S.c.scopesAt s.pc, ∃ a, sc.kind = .escape a ∧
    sc.frameOffset.toInt ≤ o ∧ o < sc.frameOffset.toInt + sc.size
  have hK0 : KInv P InEsc s.st := by
    intro o ho
    obtain ⟨-, -, hpriv, hd⟩ := h.patch o ho
    refine .inl ⟨hpriv, fun hio => ?_⟩
    rcases hd with hdead | ⟨hb, -⟩
    · obtain ⟨sc, hsc, a, hk, h1, h2⟩ := hio
      exact (not_dead_of_escape C h.lt hsc hk h1 h2 hdead).elim
    · simp only [OpSem.State.byteAt, hpriv] at hb
      exact Except.ok.inj hb
  obtain ⟨s1, hs1, rfl, -⟩ := scopes_erase_aux P InEsc (S.virt xh) _
    (fun sc hsc a hk o h1 h2 => ⟨sc, hsc, a, hk, h1, h2⟩) hr hK0 hsc
  exact ⟨s1, hs1, rfl⟩

/-- A byte live into `y` means `y` is an instruction (`liveIn` has one entry per instruction). -/
theorem lt_of_live (C : Cert S) {y i : Nat} (h : (C.fl.liveIn[y]!).testBit i = true) :
    y < S.c.d.insns.size := by
  have h1 := (postFix_spec C.hlive).1
  have hssz : C.fl.succ.size = S.c.d.insns.size := by rw [flowOf_succ C.hfl, flow_succ_size]
  refine Classical.byContradiction fun hge => ?_
  rw [getElem!_neg C.fl.liveIn y (by omega)] at h
  have h0 : (default : Nat) = 0 := rfl
  rw [h0, Nat.zero_testBit] at h
  cases h

theorem byteAt_of_frame {st : OpSem.State} {o : Int} (he : st.escapedAt o = none)
    (hf : st.frame o = .uninit) : st.byteAt o = .ok .uninit := by
  simp only [OpSem.State.byteAt, he, hf]
  all_goals rfl

/-- A byte of `P` an `End` before `pc` covers holds no ghost value after the scopes. -/
theorem ends_noGhost (C : Cert S) {s s1 : R.RState} {P : Int → Prop} (h : StepPre S C s P)
    (hs1 : (S.c.scopesAt s.pc).foldlM R.applyScope s = .ok s1)
    (hends : C.fl.ends[s.pc]! = (Frame.scopesAt S.c.d)[s.pc]!.filterMap fun (_, sc) =>
      if sc.kind == .end then some (Frame.range S.c.d.frameSize sc.frameOffset sc.size) else none)
    {o : Int} (hpo : P o) (heb : C.fl.ends[s.pc]!.bits.testBit (bit S o) = true) :
    NoGhost s1.st o := by
  obtain ⟨hif, -, -, -⟩ := h.patch o hpo
  rw [hends, testBit_rangesBits] at heb
  obtain ⟨r, hr, hri⟩ := List.any_eq_true.1 heb
  obtain ⟨⟨j, sc⟩, hjm, hjr⟩ := List.mem_filterMap.1 hr
  by_cases hk : sc.kind = .end
  · simp [hk] at hjr
    subst hjr
    have hsc' := mem_scopesAt_of_frame hjm S.c rfl
    simp only [Bool.and_eq_true, decide_eq_true_eq] at hri
    obtain ⟨hr1, hr2⟩ := hri
    obtain ⟨hf1, hf2⟩ := hif
    simp only [Frame.range, bit] at hr1 hr2
    exact noGhost_foldlM _ hs1 (.inr ⟨sc, hsc', hk, by omega, by omega⟩)
  · simp [hk] at hjr

theorem flow_edges_get {fl : Frame.Flow} {k : Nat} (h1 : k < fl.succ.size) (h2 : k < fl.pad.size) :
    fl.edges[k]! = fl.succ[k]! ++ fl.pad[k]! := by
  unfold Frame.Flow.edges
  rw [getElem!_pos _ k (by simp; omega), getElem!_pos fl.succ k h1, getElem!_pos fl.pad k h2]
  simp

/-- T3c: a `jmp` to a target in range. `P'` keeps the bytes of `P` still private and dead into
the target (or `Uninit` there and cache-covered); the others hold no ghost value (`NoGhost`): an
`End` before the `jmp` covers them, or they were `Uninit` already. -/
theorem rnext_erase_jmp (C : Cert S) {s t' : R.RState} {P : Int → Prop} (h : StepPre S C s P)
    {op : Reduced.Opcode} {f : Full.Opcode} {tg : Nat}
    (hi : S.c.d.insns[s.pc]? = some (.native op [.target tg])) (hf : op.full = some f)
    (hs : f.info.shape = .jmp) (htg : tg < S.c.d.insns.size)
    (hn : RNext S.c (erase s P) t') : StepOut S C s P t' := by
  have hi' : S.c.d.insns[(erase s P).pc]? = some (.native op [.target tg]) := hi
  have hst : ∃ ch, R.step S.c (erase s P) ch = .ok (.step t') := by
    cases hn with
    | step hstep => exact ⟨_, hstep⟩
    | answer hstep _ =>
      obtain ⟨_, _, hc⟩ := step_jmp_ok hi' hf hs hstep
      cases hc
  obtain ⟨ch, hstep⟩ := hst
  obtain ⟨t1, hsc, hc⟩ := step_jmp_ok hi' hf hs hstep
  cases hc
  obtain ⟨s1, hs1, rfl⟩ := scopes_erase_eq C h hsc
  -- the flow at `pc`
  have hlt := h.lt
  have hshr : op.info.shape = .jmp := (reduced_shape hf).trans hs
  have hni : (op.full.bind Asm.classOf).isSome = false := by
    cases hb : (op.full.bind Asm.classOf).isSome
    · rfl
    · exact (h.notInline ⟨op, _, hi, hb⟩).elim
  obtain ⟨hkill, hun, hends⟩ := flowOf_jmp_row C.hfl hi hshr hni
  have hsucc : C.fl.succ = (Frame.flow S.c.d).1 := flowOf_succ C.hfl
  have hssz : C.fl.succ.size = S.c.d.insns.size := by rw [hsucc, flow_succ_size]
  have hpsz : C.fl.pad.size = C.fl.succ.size := (postFix_spec C.hlive).2.1
  have htin : tg ∈ C.fl.succ[s.pc]! := by
    rw [hsucc]; exact flow_succ_target hi (List.mem_singleton_self _) htg
  let s' : R.RState := { s1 with pc := tg }
  let P' : Int → Prop := fun o => P o ∧ s'.st.escapedAt o = none ∧
    (Dead S C tg o ∨ (s'.st.byteAt o = .ok .uninit ∧ CacheCovers S tg o))
  -- a byte of `P` that leaves holds no ghost value
  have hleave : ∀ o, P o → ¬ P' o → NoGhost s1.st o := by
    intro o ho hno
    by_cases hesc : s1.st.escapedAt o = none
    · obtain ⟨hif, -, hpriv, hd⟩ := h.patch o ho
      have hnd : ¬ Dead S C tg o := fun hd' => hno ⟨ho, hesc, .inl hd'⟩
      rcases hd with hdead | ⟨hb, -⟩
      · -- live into the target, dead into `pc`: an `End` before `pc` covers it
        have hlive : (C.fl.liveIn[tg]!).testBit (bit S o) = true := by
          cases hb : (C.fl.liveIn[tg]!).testBit (bit S o)
          · exact (hnd ⟨hif, hb⟩).elim
          · rfl
        have hend : C.fl.ends[s.pc]!.bits.testBit (bit S o) = true := by
          cases he : C.fl.ends[s.pc]!.bits.testBit (bit S o)
          · have := live_succ C.hlive (by rw [hssz]; exact hlt) htin hlive
              (by rw [hkill]; simp [Frame.Ranges.bits]) (by rw [hun]; simp [Frame.Ranges.bits]) he
            rw [hdead.2] at this
            cases this
          · rfl
        rw [hends, testBit_rangesBits] at hend
        obtain ⟨r, hr, hri⟩ := List.any_eq_true.1 hend
        obtain ⟨⟨j, sc⟩, hjm, hjr⟩ := List.mem_filterMap.1 hr
        by_cases hk : sc.kind = .end
        · simp [hk] at hjr
          subst hjr
          have hsc' := mem_scopesAt_of_frame hjm S.c rfl
          simp only [Bool.and_eq_true, decide_eq_true_eq] at hri
          obtain ⟨hr1, hr2⟩ := hri
          obtain ⟨hf1, hf2⟩ := hif
          simp only [Frame.range, bit] at hr1 hr2
          exact noGhost_foldlM _ hs1 (.inr ⟨sc, hsc', hk, by omega, by omega⟩)
        · simp [hk] at hjr
      · refine noGhost_foldlM _ hs1 (.inl (.inr ?_))
        simp only [OpSem.State.byteAt, hpriv] at hb
        exact Except.ok.inj hb
    · exact .inl hesc
  refine ⟨s', P', fun o ho => ho.1,
    .inr fun o _ _ => by rw [hkill]; simp [Frame.Ranges.bits],
    fun o ho _ _ heb => byteAt_of_frame ho.2.1
      ((ends_noGhost C h hs1 hends ho.1 heb).resolve_left (fun hne => hne ho.2.1)),
    RNext.step (ch := ch) (step_jmp_of hi hf hs hs1), ⟨rfl, rfl, rfl, ?_⟩,
    fun o ho => ?_, fun o ho => ?_, ?_⟩
  · -- `StEq`: equal but where a byte left `P`, which holds no ghost value
    refine ⟨rfl, rfl, rfl, rfl, rfl, fun o ho => ?_⟩
    simp only [erase, eraseSt]
    by_cases hp' : P' o
    · simp only [hp', ↓reduceIte]
    · by_cases hp : P o
      · simp only [hp', hp, ↓reduceIte]
        rcases hleave o hp hp' with hq | hq
        · exact (hq ho).elim
        · exact hq
      · simp only [hp', hp, ↓reduceIte]
        all_goals rfl
  · -- the shadow's bytes at `P'` are `Uninit`
    obtain ⟨hp, hpr, -⟩ := ho
    show (eraseSt P s1.st).byteAt o = .ok .uninit
    have hn' : (eraseSt P s1.st).escapedAt o = none := hpr
    simp only [OpSem.State.byteAt, hn']
    simp only [eraseSt, hp, ↓reduceIte]
    all_goals rfl
  · obtain ⟨hp, hpr, hd⟩ := ho
    obtain ⟨hif, hdr, -, -⟩ := h.patch o hp
    exact ⟨hif, hdr, hpr, hd⟩
  · -- escape soundness along the edge
    intro _
    have hedge : tg ∈ C.fl.edges[s.pc]! := by
      rw [flow_edges_get (by rw [hssz]; exact hlt) (by rw [hpsz, hssz]; exact hlt)]
      exact List.mem_append_left _ htin
    exact escPre_next C.hesc hlt h.esc hs1 rfl hedge

/-! ### `unreachable` (T3c) -/

/-- A step that succeeds ran the scopes. -/
theorem step_scopes_ok {c : R.Code} {s : R.RState} {ch : OpSem.Choice} {o : R.Out}
    (h : R.step c s ch = .ok o) : ∃ s1, (c.scopesAt s.pc).foldlM R.applyScope s = .ok s1 := by
  unfold R.step at h
  cases hi : c.d.insns[s.pc]? with
  | none => rw [hi] at h; cases h
  | some i =>
    rw [hi] at h
    cases hsc : (c.scopesAt s.pc).foldlM R.applyScope s with
    | error e => rw [hsc] at h; cases h
    | ok s1 => exact ⟨s1, rfl⟩

/-- T3c: `unreachable` has no successor: R's step throws `unreachable`. -/
theorem rnext_erase_unreachable {s t' : R.RState} {P : Int → Prop} {op : Reduced.Opcode}
    (hi : S.c.d.insns[s.pc]? = some (.native op [])) (hf : op.full = some .unreachable)
    (hn : RNext S.c (erase s P) t') : False := by
  have hi' : S.c.d.insns[(erase s P).pc]? = some (.native op []) := hi
  have key : ∀ ch o, R.step S.c (erase s P) ch = .ok o → False := by
    intro ch o hst
    obtain ⟨t1, hsc⟩ := step_scopes_ok hst
    rw [(Ryo.Proofs.Shapes.unreachable_step S.ctx (x := S.x0) (ch := ch) hi' hf hsc).2] at hst
    cases hst
  cases hn with
  | step hs => exact key _ _ hs
  | answer hs _ => exact key _ _ hs

/-! ### `arg` (T3c) -/

/-- `ArgReg.of?` accepts only 32-bit words (`word` is `u32`). -/
theorem argReg_of_lt {n : Nat} {b : Bool} {a : Asm.ArgReg} (h : Asm.ArgReg.of? n b = some a) :
    n < 2 ^ 32 := by
  refine Classical.byContradiction fun hge => ?_
  have hw : ∀ x : Asm.ArgReg, x.word ≠ n := fun x hx => by
    have : x.word < 2 ^ 32 := Nat.mod_lt _ (Nat.two_pow_pos 32)
    omega
  have hn : Asm.ArgReg.of? n b = none := by simp [Asm.ArgReg.of?, hw]
  rw [hn] at h
  cases h

set_option maxRecDepth 100000 in
theorem reduced_argOpsTable : (List.range Reduced.toFullTable.size).all (fun i =>
    match Reduced.toFullTable[i]! with
    | some f => f.info.shape != .arg ||
        ((Reduced.Opcode.info ⟨i.toUInt16⟩).operands.map (·.name)) == ["d", "r"]
    | none => true) = true := by
  decide +kernel

/-- A reduced opcode of `arg` shape has the operands `d`, `r`. -/
theorem reduced_arg_ops {op : Reduced.Opcode} {f : Full.Opcode} (h : op.full = some f)
    (hs : f.info.shape = .arg) : op.info.operands.map (·.name) = ["d", "r"] := by
  unfold Reduced.Opcode.full at h
  have hlt : op.val.toNat < Reduced.toFullTable.size := Classical.byContradiction fun hn => by
    rw [getElem!_neg Reduced.toFullTable op.val.toNat hn] at h
    cases h
  have := List.all_eq_true.1 reduced_argOpsTable op.val.toNat (List.mem_range.2 hlt)
  rw [h] at this
  simp only [hs, bne_self_eq_false, Bool.false_or, beq_iff_eq] at this
  have hop : (⟨op.val.toNat.toUInt16⟩ : Reduced.Opcode) = op := by cases op; simp
  rw [hop] at this
  exact this

/-- `arg d, r`'s frame operands: a write of the register's size at `d`. -/
theorem native_arg_opnds {op : Reduced.Opcode} (hs : op.info.shape = .arg)
    (hn : op.info.operands.map (·.name) = ["d", "r"]) {d : BitVec 32} {r : BitVec 64}
    {a : Asm.ArgReg} (ha : Asm.ArgReg.of? r.toNat true = some a) (pe : Bool)
    (lends : List (BitVec 32 × Nat)) (tmpl : Option String) :
    (Frame.native op [.slot d, .imm r] pe lends tmpl).opnds = [(d, .write a.size)] := by
  obtain ⟨o1, o2, hops, h1, h2⟩ : ∃ o1 o2, op.info.operands = [o1, o2] ∧ o1.name = "d" ∧
      o2.name = "r" := by
    cases hq : op.info.operands with
    | nil => rw [hq] at hn; cases hn
    | cons o1 t =>
      cases t with
      | nil => rw [hq] at hn; simp at hn
      | cons o2 t =>
        cases t with
        | nil =>
          rw [hq] at hn
          simp only [List.map_cons, List.map_nil, List.cons.injEq, and_true] at hn
          exact ⟨o1, o2, rfl, hn.1, hn.2⟩
        | cons _ _ => rw [hq] at hn; simp at hn
  have hlt := argReg_of_lt ha
  unfold Frame.native
  simp [hs, hops, h1, h2, Nat.mod_eq_of_lt hlt, ha]

/-- At a non-inline `arg d, r`, `Flow.of` kills the written slot, makes nothing `Uninit`, and its
`ends` are the `End` scopes before it. -/
theorem flowOf_arg_row {d : Decoded} {mode : Ryo.Obj.Mode} {facts : Frame.Facts} {fl : Frame.Flow}
    (h : Frame.Flow.of d mode facts = .ok fl) {k : Nat} {op : Reduced.Opcode} {f : Full.Opcode}
    {sl : BitVec 32} {r : BitVec 64} {a : Asm.ArgReg}
    (hi : d.insns[k]? = some (.native op [.slot sl, .imm r])) (hf : op.full = some f)
    (hs : f.info.shape = .arg) (ha : Asm.ArgReg.of? r.toNat true = some a)
    (hni : (op.full.bind Asm.classOf).isSome = false) :
    fl.kill[k]! = [Frame.range d.frameSize sl a.size] ∧ fl.uninit[k]! = [] ∧
      fl.ends[k]! = (Frame.scopesAt d)[k]!.filterMap fun (_, sc) =>
        if sc.kind == .end then some (Frame.range d.frameSize sc.frameOffset sc.size) else none := by
  have hk : k < d.insns.size := by
    rcases Nat.lt_or_ge k d.insns.size with h | h
    · exact h
    · rw [Array.getElem?_eq_none h] at hi; cases hi
  have hik : d.insns[k]! = .native op [.slot sl, .imm r] := by
    rw [getElem!_pos d.insns k hk]
    rw [Array.getElem?_eq_getElem hk] at hi
    exact Option.some.inj hi
  have hshr : op.info.shape = .arg := (reduced_shape hf).trans hs
  obtain ⟨e, he, rr, ⟨eb, rfl⟩, hkl, hun, hen⟩ := flowOf_row h hk
  rw [hik] at he
  simp only [Frame.effects, hni, Bool.false_eq_true, ↓reduceIte, pure, Except.pure,
    Except.ok.injEq] at he
  subst he
  have hop := native_arg_opnds (d := sl) hshr (reduced_arg_ops hf hs) ha mode.pe
    (Frame.Flow.lendsOf (Frame.scopesAt d) k) (facts.islandTemplate k)
  refine ⟨?_, ?_, ?_⟩
  · rw [hkl]
    simp only [Frame.Flow.rowOf, hop]
    rfl
  · rw [hun]
    simp only [Frame.Flow.rowOf, Frame.Flow.callInfo, hik, hshr]
    rfl
  · rw [hen]
    rfl

/-- The fall-through of a non-jumping native instruction, in range, is a `flow` successor. -/
theorem flow_succ_next {d : Decoded} {k : Nat} {op : Reduced.Opcode} {ops : List (Opnd Nat)}
    (hi : d.insns[k]? = some (.native op ops)) (hs : op.info.shape = .arg)
    (hn : k + 1 < d.insns.size) : k + 1 ∈ (Frame.flow d).1[k]! := by
  have hk : k < d.insns.size := by omega
  unfold Frame.flow
  simp only [Id.run_bind, Id.run_pure, Std.Legacy.Range.forIn'_eq_forIn'_range',
    Std.Legacy.Range.size]
  refine forIn'_push_mem (R := fun a x => ∀ op ops, d.insns[a]? = some (.native op ops) →
    op.info.shape = .arg → a + 1 < d.insns.size → a + 1 ∈ x) _ ?_ (by simpa using hk)
    (fun x hR => hR op ops hi hs hn)
  intro a h b
  refine ⟨_, rfl, ?_⟩
  intro op' ops' hop hs' hn'
  have hd : ∀ hh : a < d.insns.size, d.insns[a]'hh = .native op' ops' := fun hh => by
    rw [Array.getElem?_eq_getElem hh] at hop
    exact Option.some.inj hop
  simp only [hd]
  simp [hs', hn']

theorem step_arg_ok {c : R.Code} {s : R.RState} {ch : OpSem.Choice} {o : R.Out}
    {op : Reduced.Opcode} {f : Full.Opcode} {d : BitVec 32} {r : BitVec 64}
    (hi : c.d.insns[s.pc]? = some (.native op [.slot d, .imm r])) (hf : op.full = some f)
    (hsh : f.info.shape = .arg) (h : R.step c s ch = .ok o) :
    ∃ s1 a st', (c.scopesAt s.pc).foldlM R.applyScope s = .ok s1 ∧
      Asm.ArgReg.of? r.toNat true = some a ∧
      s1.st.writeFrame d.toInt ((s1.args.get (.ofArgReg a)).take a.size) = .ok st' ∧
      o = .step { s1 with pc := s1.pc + 1, st := st' } := by
  unfold R.step at h
  simp only [hi, bind, Except.bind] at h
  cases hsc : (c.scopesAt s.pc).foldlM R.applyScope s with
  | error e => simp [hsc] at h
  | ok s1 =>
    simp only [hsc, hf] at h
    rw [hsh] at h
    dsimp only at h
    cases ha : Asm.ArgReg.of? r.toNat true with
    | none => rw [ha] at h; cases h
    | some a =>
      rw [ha] at h
      simp only [bind, Except.bind] at h
      cases hw : s1.st.writeFrame d.toInt ((s1.args.get (.ofArgReg a)).take a.size) with
      | error e => rw [hw] at h; cases h
      | ok st' =>
        rw [hw] at h
        simp only [pure, Except.pure, Except.ok.injEq] at h
        exact ⟨s1, a, st', rfl, rfl, hw, h.symm⟩

theorem step_arg_of {c : R.Code} {s s1 : R.RState} {ch : OpSem.Choice} {st' : OpSem.State}
    {op : Reduced.Opcode} {f : Full.Opcode} {d : BitVec 32} {r : BitVec 64} {a : Asm.ArgReg}
    (hi : c.d.insns[s.pc]? = some (.native op [.slot d, .imm r])) (hf : op.full = some f)
    (hsh : f.info.shape = .arg) (hsc : (c.scopesAt s.pc).foldlM R.applyScope s = .ok s1)
    (ha : Asm.ArgReg.of? r.toNat true = some a)
    (hw : s1.st.writeFrame d.toInt ((s1.args.get (.ofArgReg a)).take a.size) = .ok st') :
    R.step c s ch = .ok (.step { s1 with pc := s1.pc + 1, st := st' }) := by
  unfold R.step
  simp only [hi, bind, Except.bind, hsc, hf]
  rw [hsh]
  dsimp only
  simp only [ha, bind, Except.bind, hw]
  all_goals rfl

/-- A frame write from the shadow is the write from the state, but for the bytes of `P` it
doesn't write. -/
theorem writeFrame_erase_gen {st st' : OpSem.State} {P : Int → Prop} {off : Int}
    {bs : List AbstractByte} (h : (eraseSt P st).writeFrame off bs = .ok st') :
    ∃ st2, st.writeFrame off bs = .ok st2 ∧ st'.escaped = st2.escaped ∧
      st'.zeroSized = st2.zeroSized ∧ st'.mem = st2.mem ∧ st'.exposed = st2.exposed ∧
      st'.exception = st2.exception ∧
      (∀ o, st'.frame o =
        if st.privateIn off bs.length o = true then st2.frame o else (eraseSt P st).frame o) ∧
      (∀ o, st.privateIn off bs.length o = false → st2.frame o = st.frame o) := by
  unfold OpSem.State.writeFrame at h ⊢
  have hW : (eraseSt P st).writeEscaped off bs = st.writeEscaped off bs := rfl
  rw [hW] at h
  cases hm : st.writeEscaped off bs with
  | error e => rw [hm] at h; cases h
  | ok m =>
    rw [hm] at h
    cases h
    refine ⟨_, rfl, rfl, rfl, rfl, rfl, rfl, fun o => ?_, fun o ho => ?_⟩
    · have hq' : (eraseSt P st).privateIn off bs.length o = st.privateIn off bs.length o := rfl
      by_cases hq : st.privateIn off bs.length o = true
      · simp only [hq', hq, ↓reduceIte]
      · simp only [hq', hq, ↓reduceIte, Bool.false_eq_true]
    · simp only [ho, Bool.false_eq_true, ↓reduceIte]

/-- T3c: `arg d, r` with its fall-through in range and the register holding at least its size's
bytes (`hlen`: R writes `take a.size` of the register's bytes, while `Flow.of` kills all `a.size`;
**to be discharged** from the entry / `ArgsLive` invariant, or a decoder fact). -/
theorem rnext_erase_arg (C : Cert S) {s t' : R.RState} {P : Int → Prop} (h : StepPre S C s P)
    {op : Reduced.Opcode} {f : Full.Opcode} {d : BitVec 32} {r : BitVec 64}
    (hi : S.c.d.insns[s.pc]? = some (.native op [.slot d, .imm r])) (hf : op.full = some f)
    (hs : f.info.shape = .arg) (hnx : s.pc + 1 ≤ S.c.d.insns.size)
    (hlen : ∀ a, Asm.ArgReg.of? r.toNat true = some a →
      a.size ≤ (s.args.get (.ofArgReg a)).length)
    (hn : RNext S.c (erase s P) t') : StepOut S C s P t' := by
  have hi' : S.c.d.insns[(erase s P).pc]? = some (.native op [.slot d, .imm r]) := hi
  have hst : ∃ ch, R.step S.c (erase s P) ch = .ok (.step t') := by
    cases hn with
    | step hstep => exact ⟨_, hstep⟩
    | answer hstep _ =>
      obtain ⟨_, _, _, _, _, _, hc⟩ := step_arg_ok hi' hf hs hstep
      cases hc
  obtain ⟨ch, hstep⟩ := hst
  obtain ⟨t1, a, st', hsc, ha, hw, hc⟩ := step_arg_ok hi' hf hs hstep
  cases hc
  obtain ⟨s1, hs1, rfl⟩ := scopes_erase_eq C h hsc
  have hpc : s1.pc = s.pc := (Ryo.Proofs.Scope.scopes_keeps _ hs1).pc
  have hargs : s1.args = s.args := (Ryo.Proofs.Scope.scopes_keeps _ hs1).args
  have hlen' : ((s1.args.get (.ofArgReg a)).take a.size).length = a.size := by
    rw [List.length_take, hargs]
    exact Nat.min_eq_left (hlen a ha)
  obtain ⟨st2, hw2, he1, hz, hm, hx, hex, hfr, hfr2⟩ :=
    writeFrame_erase_gen (st := s1.st) (P := P) hw
  have hesc2 : st2.escaped = s1.st.escaped := Ryo.Proofs.ScopeMem.writeFrame_escaped hw2
  -- the flow at `pc`
  have hlt := h.lt
  have hni : (op.full.bind Asm.classOf).isSome = false := by
    cases hb : (op.full.bind Asm.classOf).isSome
    · rfl
    · exact (h.notInline ⟨op, _, hi, hb⟩).elim
  obtain ⟨hkill, hun, hends⟩ := flowOf_arg_row C.hfl hi hf hs ha hni
  have hsucc : C.fl.succ = (Frame.flow S.c.d).1 := flowOf_succ C.hfl
  have hssz : C.fl.succ.size = S.c.d.insns.size := by rw [hsucc, flow_succ_size]
  have hpsz : C.fl.pad.size = C.fl.succ.size := (postFix_spec C.hlive).2.1
  have htin : s.pc + 1 < S.c.d.insns.size → s.pc + 1 ∈ C.fl.succ[s.pc]! := fun hyl => by
    rw [hsucc]; exact flow_succ_next hi ((reduced_shape hf).trans hs) hyl
  let s' : R.RState := { s1 with pc := s1.pc + 1, st := st2 }
  have hspc : s'.pc = s.pc + 1 := by show s1.pc + 1 = s.pc + 1; rw [hpc]
  let L := ((s1.args.get (.ofArgReg a)).take a.size).length
  let P' : Int → Prop := fun o => P o ∧ s1.st.privateIn d.toInt L o = false ∧
    s'.st.escapedAt o = none ∧
    (Dead S C s'.pc o ∨ (s'.st.byteAt o = .ok .uninit ∧ CacheCovers S s'.pc o))
  have hesc' : ∀ o, s'.st.escapedAt o = s1.st.escapedAt o := fun o => by
    show st2.escapedAt o = _
    unfold OpSem.State.escapedAt; rw [hesc2]
  -- a byte of `P` not written that leaves holds no ghost value
  have hleave : ∀ o, P o → s1.st.privateIn d.toInt L o = false → ¬ P' o →
      s1.st.escapedAt o = none → s1.st.frame o = .uninit := by
    intro o ho hnw hno hpr
    have hpr' : s'.st.escapedAt o = none := (hesc' o).trans hpr
    obtain ⟨hif, -, hpriv, hd⟩ := h.patch o ho
    have hnd : ¬ Dead S C s'.pc o := fun hd' => hno ⟨ho, hnw, hpr', .inl hd'⟩
    have hng : NoGhost s1.st o := by
      rcases hd with hdead | ⟨hb, -⟩
      · have hlive : (C.fl.liveIn[s.pc + 1]!).testBit (bit S o) = true := by
          cases hb : (C.fl.liveIn[s.pc + 1]!).testBit (bit S o)
          · rw [hspc] at hnd; exact (hnd ⟨hif, hb⟩).elim
          · rfl
        have hyl := lt_of_live C hlive
        have hkb : C.fl.kill[s.pc]!.bits.testBit (bit S o) = false := by
          rw [hkill]
          cases hkb : (Frame.Ranges.bits [Frame.range S.c.d.frameSize d a.size]).testBit (bit S o)
          · rfl
          · exfalso
            rw [testBit_rangesBits] at hkb
            simp only [List.any_cons, List.any_nil, Bool.or_false, Bool.and_eq_true,
              decide_eq_true_eq] at hkb
            obtain ⟨hr1, hr2⟩ := hkb
            obtain ⟨hf1, hf2⟩ := hif
            simp only [Frame.range, bit] at hr1 hr2
            have hin : d.toInt ≤ o ∧ o < d.toInt + L := by
              show d.toInt ≤ o ∧ o < d.toInt + ↑((s1.args.get (.ofArgReg a)).take a.size).length
              rw [hlen']
              omega
            have : s1.st.privateIn d.toInt L o = true := by
              simp only [OpSem.State.privateIn, hpr, Option.isNone_none, Bool.and_true,
                decide_eq_true_eq]
              exact hin
            rw [hnw] at this
            cases this
        have hend : C.fl.ends[s.pc]!.bits.testBit (bit S o) = true := by
          cases he : C.fl.ends[s.pc]!.bits.testBit (bit S o)
          · have := live_succ C.hlive (by rw [hssz]; exact hlt) (htin hyl) hlive hkb
              (by rw [hun]; simp [Frame.Ranges.bits]) he
            rw [hdead.2] at this
            cases this
          · rfl
        rw [hends, testBit_rangesBits] at hend
        obtain ⟨rg, hr, hri⟩ := List.any_eq_true.1 hend
        obtain ⟨⟨j, sc⟩, hjm, hjr⟩ := List.mem_filterMap.1 hr
        by_cases hk : sc.kind = .end
        · simp [hk] at hjr
          subst hjr
          have hsc' := mem_scopesAt_of_frame hjm S.c rfl
          simp only [Bool.and_eq_true, decide_eq_true_eq] at hri
          obtain ⟨hr1, hr2⟩ := hri
          obtain ⟨hf1, hf2⟩ := hif
          simp only [Frame.range, bit] at hr1 hr2
          exact noGhost_foldlM _ hs1 (.inr ⟨sc, hsc', hk, by omega, by omega⟩)
        · simp [hk] at hjr
      · refine noGhost_foldlM _ hs1 (.inl (.inr ?_))
        simp only [OpSem.State.byteAt, hpriv] at hb
        exact Except.ok.inj hb
    rcases hng with hq | hq
    · exact (hq hpr).elim
    · exact hq
  have hkP : ∀ o, P' o → InFrame S o → C.fl.kill[s.pc]!.bits.testBit (bit S o) = false := by
    intro o ho hif
    have hpr : s1.st.escapedAt o = none := (hesc' o).symm.trans ho.2.2.1
    rw [hkill]
    cases hkb : (Frame.Ranges.bits [Frame.range S.c.d.frameSize d a.size]).testBit (bit S o)
    · rfl
    · exfalso
      rw [testBit_rangesBits] at hkb
      simp only [List.any_cons, List.any_nil, Bool.or_false, Bool.and_eq_true,
        decide_eq_true_eq] at hkb
      obtain ⟨hr1, hr2⟩ := hkb
      obtain ⟨hf1, hf2⟩ := hif
      simp only [Frame.range, bit] at hr1 hr2
      have hin : d.toInt ≤ o ∧ o < d.toInt + L := by
        show d.toInt ≤ o ∧ o < d.toInt + ↑((s1.args.get (.ofArgReg a)).take a.size).length
        rw [hlen']
        omega
      have : s1.st.privateIn d.toInt L o = true := by
        simp only [OpSem.State.privateIn, hpr, Option.isNone_none, Bool.and_true,
          decide_eq_true_eq]
        exact hin
      rw [ho.2.1] at this
      cases this
  have hEU : ∀ o, P' o → InFrame S o → s'.pc ∈ C.fl.succ[s.pc]! →
      C.fl.ends[s.pc]!.bits.testBit (bit S o) = true → s'.st.byteAt o = .ok .uninit := by
    intro o ho _ _ heb
    refine byteAt_of_frame ho.2.2.1 ?_
    show st2.frame o = .uninit
    rw [hfr2 o ho.2.1]
    exact (ends_noGhost C h hs1 hends ho.1 heb).resolve_left
      (fun hne => hne ((hesc' o).symm.trans ho.2.2.1))
  refine ⟨s', P', fun o ho => ho.1, .inr hkP, hEU, RNext.step (ch := ch) (step_arg_of hi hf hs hs1 ha hw2), ⟨?_, rfl, rfl, ?_⟩,
    fun o ho => ?_, fun o ho => ?_, ?_⟩
  · show s1.pc + 1 = (erase s1 P).pc + 1
    rfl
  · refine ⟨he1.symm, hz.symm, hm.symm, hx.symm, hex.symm, fun o ho => ?_⟩
    have hpr2 : st2.escapedAt o = none := ho
    have hpr : s1.st.escapedAt o = none := (hesc' o).symm.trans hpr2
    simp only [eraseSt]
    by_cases hp' : P' o
    · simp only [hp', ↓reduceIte]
    · simp only [hp', ↓reduceIte]
      rw [hfr o]
      split
      · rfl
      · rename_i hq
        have hq' : s1.st.privateIn d.toInt L o = false := by
          cases hb : s1.st.privateIn d.toInt L o
          · rfl
          · exact (hq hb).elim
        rw [hfr2 o hq']
        simp only [eraseSt]
        by_cases hp : P o
        · simp only [hp, ↓reduceIte]
          exact hleave o hp hq' hp' hpr
        · simp only [hp, ↓reduceIte]
  · -- the shadow's bytes at `P'` are `Uninit`
    obtain ⟨hp, hnw, hpr, -⟩ := ho
    have hpr1 : s1.st.escapedAt o = none := (hesc' o).symm.trans hpr
    have hn' : st'.escapedAt o = none := by
      unfold OpSem.State.escapedAt; rw [he1, hesc2]; exact hpr1
    show st'.byteAt o = .ok .uninit
    simp only [OpSem.State.byteAt, hn']
    rw [hfr o]
    have hnw' : s1.st.privateIn d.toInt
        (List.take a.size ((erase s1 P).args.get (.ofArgReg a))).length o = false := hnw
    simp only [hnw', Bool.false_eq_true, ↓reduceIte, eraseSt, hp]
    all_goals rfl
  · obtain ⟨hp, -, hpr, hd⟩ := ho
    obtain ⟨hif, hdr, -, -⟩ := h.patch o hp
    exact ⟨hif, hdr, hpr, hd⟩
  · intro hyl
    have hedge : s.pc + 1 ∈ C.fl.edges[s.pc]! := by
      rw [flow_edges_get (by rw [hssz]; exact hlt) (by rw [hpsz, hssz]; exact hlt)]
      exact List.mem_append_left _ (htin (by rw [← hspc]; exact hyl))
    unfold EscSound
    rw [hspc]
    exact escPre_next C.hesc hlt h.esc hs1 hesc2 hedge

/-! ### Handlers: the row (T3a) -/

/-- Instruction `k`'s row of `Flow.of`, with its operand reads. -/
theorem flowOf_row4 {d : Decoded} {mode : Ryo.Obj.Mode} {facts : Frame.Facts} {fl : Frame.Flow}
    (h : Frame.Flow.of d mode facts = .ok fl) {k : Nat} (hk : k < d.insns.size) :
    ∃ e, Frame.effects d.insns[k]! (d.items[k]?.getD []) mode
        (Frame.Flow.lendsOf (Frame.scopesAt d) k) (facts.islandTemplate k) = .ok e ∧
      ∃ eb, fl.kill[k]! = (Frame.Flow.rowOf d facts (Frame.scopesAt d) k e eb).kill ∧
        fl.uninit[k]! = (Frame.Flow.rowOf d facts (Frame.scopesAt d) k e eb).uninit ∧
        fl.ends[k]! = (Frame.Flow.rowOf d facts (Frame.scopesAt d) k e eb).ends ∧
        fl.operand[k]! = (Frame.Flow.rowOf d facts (Frame.scopesAt d) k e eb).operand := by
  unfold Frame.Flow.of at h
  simp only [bind, Except.bind] at h
  split at h
  · cases h
  · rename_i rows hr
    simp only [pure, Except.pure, Except.ok.injEq] at h
    subst h
    obtain ⟨r, hrow, hr2⟩ := mapM_except_ok _ _ rows hr k (by simpa using hk)
    simp only [List.getElem_range] at hrow
    unfold Frame.Flow.row at hrow
    simp only [bind, Except.bind] at hrow
    split at hrow
    · cases hrow
    · rename_i e he
      simp only [pure, Except.pure, Except.ok.injEq] at hrow
      obtain ⟨eb, hrow'⟩ : ∃ eb, Frame.Flow.rowOf d facts (Frame.scopesAt d) k e eb = r :=
        ⟨_, hrow⟩
      refine ⟨e, he, eb, ?_, ?_, ?_, ?_⟩ <;>
        · rw [hrow']
          simp [Array.getElem!_eq_getD, Array.getD_eq_getD_getElem?, hr2]

/-- At a handler instruction `k`: its effects are `Frame.handler`'s; it kills what they write
for sure, makes nothing `Uninit`, reads (by operand) what they read, and its `ends` are the `End`
scopes before it. -/
theorem flowOf_handler_row {d : Decoded} {mode : Ryo.Obj.Mode} {facts : Frame.Facts}
    {fl : Frame.Flow} (h : Frame.Flow.of d mode facts = .ok fl) {k : Nat} {hh : Full.Opcode}
    {args : List Arg} {t : Then Nat} (hi : d.insns[k]? = some (.handler hh args t)) :
    ∃ e eb, Frame.handler hh args mode = .ok e ∧
      fl.kill[k]! = (Frame.Flow.opndRanges d.frameSize false eb e.opnds).2 ∧
      fl.uninit[k]! = [] ∧
      (∀ r ∈ (Frame.Flow.opndRanges d.frameSize false eb e.opnds).1, r ∈ fl.operand[k]!) ∧
      fl.ends[k]! = (Frame.scopesAt d)[k]!.filterMap fun (_, sc) =>
        if sc.kind == .end then some (Frame.range d.frameSize sc.frameOffset sc.size) else none := by
  have hk : k < d.insns.size := by
    rcases Nat.lt_or_ge k d.insns.size with h | h
    · exact h
    · rw [Array.getElem?_eq_none h] at hi; cases hi
  have hik : d.insns[k]! = .handler hh args t := by
    rw [getElem!_pos d.insns k hk]
    rw [Array.getElem?_eq_getElem hk] at hi
    exact Option.some.inj hi
  obtain ⟨e, he, eb, hkl, hun, hen, hop⟩ := flowOf_row4 h hk
  rw [hik] at he
  simp only [Frame.effects] at he
  refine ⟨e, eb, he, ?_, ?_, fun r hr => ?_, ?_⟩
  · rw [hkl]
    simp only [Frame.Flow.rowOf, Frame.Flow.callInfo, hik]
  · rw [hun]
    simp only [Frame.Flow.rowOf, Frame.Flow.callInfo, hik]
  · rw [hop]
    simp only [Frame.Flow.rowOf, Frame.Flow.callInfo, hik]
    exact List.mem_append_left _ hr
  · rw [hen]
    rfl

/-! ### Handlers: R's step (T3a) -/

/-- A handler instruction's view: its opcode, and its control flow. -/
theorem view_handler {mode : Ryo.Obj.Mode} {ρ : R.Addrs} {h : Full.Opcode} {args : List R.Arg}
    {t : R.Then Nat} {v : R.View} (hv : R.view mode ρ (.handler h args t) = some v) :
    v.op = h ∧ v.ctl = some t := by
  simp only [R.view, Option.bind_eq_bind] at hv
  split at hv
  · cases hv
  cases hu : R.unpack ρ h mode args with
  | none => simp [hu] at hv
  | some vals =>
    simp only [hu, Option.bind_some] at hv
    split at hv <;> simp_all <;>
      first | (subst hv; exact ⟨rfl, rfl⟩) | (obtain ⟨-, rfl⟩ := hv; exact ⟨rfl, rfl⟩)

/-- `stepView` of a handler instruction (not `resume` or `unreachable`): `opSem`, then
`clearHome`, then the control flow. -/
theorem stepView_handler_ok {c : R.Code} {s : R.RState} {ch : OpSem.Choice} {h : Full.Opcode}
    {args : List R.Arg} {t : R.Then Nat} {o : R.Out} (hres : h ≠ .resume)
    (hun : h ≠ .unreachable) (hv : R.stepView c s (.handler h args t) ch = .ok o) :
    ∃ v ctl st st2 pc', R.view c.mode c.ρ (.handler h args t) = some v ∧ v.op = h ∧
      OpSem.opSem v.op v.ops s.st ch = .ok (ctl, st) ∧
      R.clearHome c.mode.pe args.length (-(c.d.frameSize : Int)) st = .ok st2 ∧
      t.succ s.pc ctl = some pc' ∧ o = .step { s with pc := pc', st := st2 } := by
  unfold R.stepView at hv
  generalize hview : R.view c.mode c.ρ (.handler h args t) = ov at hv
  cases ov with
  | none => simp [OpSem.illFormed, throw, throwThe, MonadExceptOf.throw] at hv
  | some v =>
    obtain ⟨hop, hctl⟩ := view_handler hview
    have h1 : (v.op == .resume) = false := by simp [hop, hres]
    have h2 : (v.op == .unreachable) = false := by simp [hop, hun]
    simp only [hctl, h1, h2, Bool.false_eq_true, ↓reduceIte, bind, Except.bind] at hv
    generalize ho : OpSem.opSem v.op v.ops s.st ch = oo at hv
    cases oo with
    | error e => simp at hv
    | ok r =>
      obtain ⟨ctl, st⟩ := r
      try simp only at hv
      generalize hch : R.clearHome c.mode.pe args.length (-(c.d.frameSize : Int)) st = oc at hv
      cases oc with
      | error e => simp at hv
      | ok st2 =>
        try simp only at hv
        generalize hp : t.succ s.pc ctl = op' at hv
        cases op' with
        | none => simp [OpSem.illFormed, throw, throwThe, MonadExceptOf.throw] at hv
        | some pc' =>
          simp only [pure, Except.pure, Except.ok.injEq] at hv
          exact ⟨v, ctl, st, st2, pc', rfl, hop, ho, hch, hp, hv.symm⟩

/-- The converse: `opSem`, `clearHome` and the control flow give `stepView`'s step. -/
theorem stepView_handler_of {c : R.Code} {s : R.RState} {ch : OpSem.Choice} {h : Full.Opcode}
    {args : List R.Arg} {t : R.Then Nat} {v : R.View} {ctl : OpSem.Control}
    {st st2 : OpSem.State} {pc' : Nat} (hres : h ≠ .resume) (hun : h ≠ .unreachable)
    (hview : R.view c.mode c.ρ (.handler h args t) = some v) (hop : v.op = h)
    (ho : OpSem.opSem v.op v.ops s.st ch = .ok (ctl, st))
    (hch : R.clearHome c.mode.pe args.length (-(c.d.frameSize : Int)) st = .ok st2)
    (hp : t.succ s.pc ctl = some pc') :
    R.stepView c s (.handler h args t) ch = .ok (.step { s with pc := pc', st := st2 }) := by
  have hctl := (view_handler hview).2
  have h1 : (v.op == .resume) = false := by simp [hop, hres]
  have h2 : (v.op == .unreachable) = false := by simp [hop, hun]
  unfold R.stepView
  simp only [hview, hctl, h1, h2, Bool.false_eq_true, ↓reduceIte, bind, Except.bind, ho, hch, hp]
  all_goals rfl

/-- R's step of a handler instruction (not `resume` or `unreachable`). -/
theorem step_handler_ok {c : R.Code} {s : R.RState} {ch : OpSem.Choice} {h : Full.Opcode}
    {args : List R.Arg} {t : R.Then Nat} {o : R.Out}
    (hi : c.d.insns[s.pc]? = some (.handler h args t)) (hres : h ≠ .resume)
    (hun : h ≠ .unreachable) (hs : R.step c s ch = .ok o) :
    ∃ s1 v ctl st st2 pc', (c.scopesAt s.pc).foldlM R.applyScope s = .ok s1 ∧
      R.view c.mode c.ρ (.handler h args t) = some v ∧ v.op = h ∧
      OpSem.opSem v.op v.ops s1.st ch = .ok (ctl, st) ∧
      R.clearHome c.mode.pe args.length (-(c.d.frameSize : Int)) st = .ok st2 ∧
      t.succ s1.pc ctl = some pc' ∧ o = .step { s1 with pc := pc', st := st2 } := by
  obtain ⟨s1, hsc⟩ := step_scopes_ok hs
  rw [Ryo.Proofs.Shapes.step_handler hi hsc] at hs
  obtain ⟨v, ctl, st, st2, pc', hv, hop, ho, hch, hp, rfl⟩ := stepView_handler_ok hres hun hs
  exact ⟨s1, v, ctl, st, st2, pc', hsc, hv, hop, ho, hch, hp, rfl⟩

/-! ### Handlers: the shadow's `opSem` (T3a) -/

set_option maxRecDepth 8000 in
/-- `opSem` from the shadow is `opSem` from the state, when every byte of `P` the footprint
reads is `Uninit` there: the same control, memory etc., and frames that are equal wherever
either changed (`FrameRel`). -/
theorem opSem_erase {op : Full.Opcode} {ops : OpSem.Operands} {st : OpSem.State}
    {P : Int → Prop} {ch : OpSem.Choice} {fp : OpSem.Footprint} {r : OpSem.Control × OpSem.State}
    (hfp : OpSem.footprint op = some fp)
    (hrd : ∀ o, (∃ rg ∈ fp.readRanges (OpSem.opndVal op.info ops), OpSem.inRange o rg = true) →
      P o → st.frame o = .uninit)
    (h : OpSem.opSem op ops (eraseSt P st) ch = .ok r) :
    ∃ r2, OpSem.opSem op ops st ch = .ok r2 ∧ r.1 = r2.1 ∧
      OpSem.FrameRel (eraseSt P st).frame st.frame r.2 r2.2 := by
  have hs : (eraseSt P st).SameButFrame st := ⟨rfl, rfl, rfl, rfl, rfl⟩
  have hf : ∀ o, (∃ rg ∈ fp.readRanges (OpSem.opndVal op.info ops), OpSem.inRange o rg = true) →
      (eraseSt P st).frame o = st.frame o := by
    intro o ho
    by_cases hp : P o
    · simp only [eraseSt, hp, ↓reduceIte]
      exact (hrd o ho hp).symm
    · simp only [eraseSt, hp, ↓reduceIte]
  have hrr := OpSem.opSem_reads_footprint (op := op) (ops := ops) (st1 := eraseSt P st)
    (st2 := st) (ch := ch) (fp := fp) hfp hs hf
  rw [h] at hrr
  cases h2 : OpSem.opSem op ops st ch with
  | error e =>
    rw [h2] at hrr
    simp only [OpSem.ResultRel] at hrr
  | ok r2 =>
    rw [h2] at hrr
    exact ⟨r2, rfl, hrr.1, hrr.2⟩

/-- A scope keeps a private `Uninit` frame field `Uninit` (an `Escape` doesn't touch the frame
field; an `End` writes `Uninit`). -/
theorem applyScope_frame_uninit {u u' : R.RState} {sc : R.Scope}
    (h : R.applyScope u sc = .ok u') {o : Int} (hu : u.st.frame o = .uninit) :
    u'.st.frame o = .uninit := by
  unfold R.applyScope at h
  split at h
  · rcases Ryo.Proofs.Scope.escape_ok h with rfl | ⟨_, _, _, _, _, _, _, _, rfl⟩
    · exact hu
    · exact hu
  · obtain ⟨st', hw, rfl⟩ := Ryo.Proofs.Scope.storageEnd_ok h
    obtain ⟨_, -, -, -, hfrm⟩ := writeFrame_parts hw
    show st'.frame o = .uninit
    rw [hfrm o]
    split
    · exact getD_replicate_uninit _ _
    · exact hu
  · cases h
    exact hu

theorem foldlM_frame_uninit {o : Int} : ∀ (l : List R.Scope) {u u1 : R.RState},
    l.foldlM R.applyScope u = .ok u1 → u.st.frame o = .uninit → u1.st.frame o = .uninit
  | [], u, u1, h, hu => by cases h; exact hu
  | sc :: l, u, u1, h, hu => by
    simp only [List.foldlM_cons, bind, Except.bind] at h
    cases h1 : R.applyScope u sc with
    | error e => simp [h1] at h
    | ok u2 =>
      simp only [h1] at h
      exact foldlM_frame_uninit l h (applyScope_frame_uninit h1 hu)

/-- A byte of `P` not dead into `pc` has an `Uninit` frame field after `pc`'s scopes. -/
theorem frame_uninit_of_live (C : Cert S) {s s1 : R.RState} {P : Int → Prop}
    (h : StepPre S C s P) (hs1 : (S.c.scopesAt s.pc).foldlM R.applyScope s = .ok s1)
    {o : Int} (ho : P o) (hnd : ¬ Dead S C s.pc o) : s1.st.frame o = .uninit := by
  obtain ⟨-, -, hpriv, hd⟩ := h.patch o ho
  rcases hd with hdead | ⟨hb, -⟩
  · exact (hnd hdead).elim
  · refine foldlM_frame_uninit _ hs1 ?_
    simp only [OpSem.State.byteAt, hpriv] at hb
    exact Except.ok.inj hb

/-! ### Handlers: `clearHome` against the shadow (T3a) -/

/-- `clearHome` from the shadow is `clearHome` from the state, erased (an all-`Uninit` write). -/
theorem clearHome_erase {pe : Bool} {n : Nat} {off : Int} {st st' : OpSem.State}
    {P : Int → Prop} (h : R.clearHome pe n off (eraseSt P st) = .ok st') :
    ∃ st2, R.clearHome pe n off st = .ok st2 ∧ st' = eraseSt P st2 := by
  rcases Ryo.Proofs.Shapes.clearHome_cases h with ⟨hpe, hw⟩ | ⟨hpe, rfl⟩
  · obtain ⟨st2, hw2, rfl⟩ := writeFrame_erase hw
    subst hpe
    refine ⟨st2, ?_, rfl⟩
    unfold R.clearHome
    rw [if_pos rfl]
    exact hw2
  · subst hpe
    exact ⟨st, rfl, rfl⟩

/-! ### Handler layouts and footprints against the generated tables (DS-T8, piece 1) -/

/-- What `Frame.opndVals` and `R.unpack` need to agree on an operand's value: a slot or memory
operand's word at a multiple of 32 bits when shared (else in the low 32 bits), and a 64-bit
immediate not shared. -/
def locAgreeOk (o : OperandInfo) (loc : Asm.Loc) : Bool :=
  loc.count == 0 ||
    match o.kind with
    | .slot | .mem => if loc.shared then loc.shift % 32 == 0 else decide (loc.shift < 32)
    | .u64 | .i64 => !loc.shared
    | _ => true

/-- `locAgreeOk` for every operand of `op`, in every mode's layout. -/
def layoutAgreeOk (op : Full.Opcode) : Bool :=
  [(false, false), (true, false), (false, true), (true, true)].all fun (fa, pe) =>
    match op.layout fa pe with
    | none => true
    | some l => op.info.operands.zipIdx.all fun (o, k) => locAgreeOk o (l.locs.getD k default)

/-! The opcode tables below are checked by `decide +kernel` in chunks of 100 opcodes: one
kernel reduction over all of `Full.all` keeps every intermediate term alive and needs more
than 12 GiB; per chunk it stays under 4 GiB (`Ryo.Proofs.OpsIn`). -/

set_option maxRecDepth 100000 in
theorem layoutAgreeTable_0 : (opsIn 0 100).all layoutAgreeOk = true := by
  decide +kernel
set_option maxRecDepth 100000 in
theorem layoutAgreeTable_100 : (opsIn 100 100).all layoutAgreeOk = true := by
  decide +kernel
set_option maxRecDepth 100000 in
theorem layoutAgreeTable_200 : (opsIn 200 100).all layoutAgreeOk = true := by
  decide +kernel
set_option maxRecDepth 100000 in
theorem layoutAgreeTable_300 : (opsIn 300 100).all layoutAgreeOk = true := by
  decide +kernel
set_option maxRecDepth 100000 in
theorem layoutAgreeTable_400 : (opsIn 400 100).all layoutAgreeOk = true := by
  decide +kernel
set_option maxRecDepth 100000 in
theorem layoutAgreeTable_500 : (opsIn 500 100).all layoutAgreeOk = true := by
  decide +kernel
set_option maxRecDepth 100000 in
theorem layoutAgreeTable_600 : (opsIn 600 100).all layoutAgreeOk = true := by
  decide +kernel
set_option maxRecDepth 100000 in
theorem layoutAgreeTable_700 : (opsIn 700 100).all layoutAgreeOk = true := by
  decide +kernel
set_option maxRecDepth 100000 in
theorem layoutAgreeTable_800 : (opsIn 800 100).all layoutAgreeOk = true := by
  decide +kernel
set_option maxRecDepth 100000 in
theorem layoutAgreeTable_900 : (opsIn 900 5).all layoutAgreeOk = true := by
  decide +kernel
theorem layoutAgreeTable : Full.all.all layoutAgreeOk = true := by
  rw [all_eq_opsIn]
  have h1 : (opsIn 0 200).all layoutAgreeOk = true :=
    all_opsIn_append (m := 100) (n := 100) rfl layoutAgreeTable_0 layoutAgreeTable_100
  have h2 : (opsIn 0 300).all layoutAgreeOk = true :=
    all_opsIn_append (m := 200) (n := 100) rfl h1 layoutAgreeTable_200
  have h3 : (opsIn 0 400).all layoutAgreeOk = true :=
    all_opsIn_append (m := 300) (n := 100) rfl h2 layoutAgreeTable_300
  have h4 : (opsIn 0 500).all layoutAgreeOk = true :=
    all_opsIn_append (m := 400) (n := 100) rfl h3 layoutAgreeTable_400
  have h5 : (opsIn 0 600).all layoutAgreeOk = true :=
    all_opsIn_append (m := 500) (n := 100) rfl h4 layoutAgreeTable_500
  have h6 : (opsIn 0 700).all layoutAgreeOk = true :=
    all_opsIn_append (m := 600) (n := 100) rfl h5 layoutAgreeTable_600
  have h7 : (opsIn 0 800).all layoutAgreeOk = true :=
    all_opsIn_append (m := 700) (n := 100) rfl h6 layoutAgreeTable_700
  have h8 : (opsIn 0 900).all layoutAgreeOk = true :=
    all_opsIn_append (m := 800) (n := 100) rfl h7 layoutAgreeTable_800
  have h9 : (opsIn 0 905).all layoutAgreeOk = true :=
    all_opsIn_append (m := 900) (n := 5) rfl h8 layoutAgreeTable_900
  exact h9

/-- An `Option.bind` that is `some`: its argument is, and so is the continuation there. -/
theorem bind_some_iff' {α β : Type} {x : Option α} {f : α → Option β} {b : β} :
    x.bind f = some b ↔ ∃ a, x = some a ∧ f a = some b := by
  cases x <;> simp

/-- `bind_some_iff'` for `>>=`. -/
theorem bindM_some_iff' {α β : Type} {x : Option α} {f : α → Option β} {b : β} :
    (x >>= f) = some b ↔ ∃ a, x = some a ∧ f a = some b := by
  cases x <;> simp [bind, Option.bind]

theorem footprintOf_names {k : Handlers.HandlerKind} {ps : List String} {fp : OpSem.Footprint}
    (h : OpSem.footprintOf k ps = some fp) :
    (fp.reads ++ fp.writes).map (fun a => (a.opnd, extentNames a.extent)) = namesOf k ∧
      fp.addrs = addrsOf k := by
  cases k <;> simp only [OpSem.footprintOf, bindM_some_iff', bind_some_iff', pure,
    Option.some.injEq] at h <;>
    (repeat (obtain ⟨_, -, h⟩ := h)) <;> (try subst h) <;> exact ⟨rfl, rfl⟩

/-- `footprintOf`'s frame accesses have extents `Frame.handler` evaluates (`slotVal` and `cases`
appear only in `derefs`). -/
theorem footprintOf_lenExt {k : Handlers.HandlerKind} {ps : List String} {fp : OpSem.Footprint}
    (h : OpSem.footprintOf k ps = some fp) :
    (fp.reads ++ fp.writes).all (fun a => lenExt a.extent) = true := by
  cases k <;> simp only [OpSem.footprintOf, bindM_some_iff', bind_some_iff', pure,
    Option.some.injEq] at h <;>
    (repeat (obtain ⟨_, -, h⟩ := h)) <;> (try subst h) <;> rfl

set_option maxRecDepth 100000 in
theorem footprintNamesTable'_0 : (opsIn 0 100).all footprintNamesOk' = true := by
  decide +kernel
set_option maxRecDepth 100000 in
theorem footprintNamesTable'_100 : (opsIn 100 100).all footprintNamesOk' = true := by
  decide +kernel
set_option maxRecDepth 100000 in
theorem footprintNamesTable'_200 : (opsIn 200 100).all footprintNamesOk' = true := by
  decide +kernel
set_option maxRecDepth 100000 in
theorem footprintNamesTable'_300 : (opsIn 300 100).all footprintNamesOk' = true := by
  decide +kernel
set_option maxRecDepth 100000 in
theorem footprintNamesTable'_400 : (opsIn 400 100).all footprintNamesOk' = true := by
  decide +kernel
set_option maxRecDepth 100000 in
theorem footprintNamesTable'_500 : (opsIn 500 100).all footprintNamesOk' = true := by
  decide +kernel
set_option maxRecDepth 100000 in
theorem footprintNamesTable'_600 : (opsIn 600 100).all footprintNamesOk' = true := by
  decide +kernel
set_option maxRecDepth 100000 in
theorem footprintNamesTable'_700 : (opsIn 700 100).all footprintNamesOk' = true := by
  decide +kernel
set_option maxRecDepth 100000 in
theorem footprintNamesTable'_800 : (opsIn 800 100).all footprintNamesOk' = true := by
  decide +kernel
set_option maxRecDepth 100000 in
theorem footprintNamesTable'_900 : (opsIn 900 5).all footprintNamesOk' = true := by
  decide +kernel
theorem footprintNamesTable' : Full.all.all footprintNamesOk' = true := by
  rw [all_eq_opsIn]
  have h1 : (opsIn 0 200).all footprintNamesOk' = true :=
    all_opsIn_append (m := 100) (n := 100) rfl footprintNamesTable'_0 footprintNamesTable'_100
  have h2 : (opsIn 0 300).all footprintNamesOk' = true :=
    all_opsIn_append (m := 200) (n := 100) rfl h1 footprintNamesTable'_200
  have h3 : (opsIn 0 400).all footprintNamesOk' = true :=
    all_opsIn_append (m := 300) (n := 100) rfl h2 footprintNamesTable'_300
  have h4 : (opsIn 0 500).all footprintNamesOk' = true :=
    all_opsIn_append (m := 400) (n := 100) rfl h3 footprintNamesTable'_400
  have h5 : (opsIn 0 600).all footprintNamesOk' = true :=
    all_opsIn_append (m := 500) (n := 100) rfl h4 footprintNamesTable'_500
  have h6 : (opsIn 0 700).all footprintNamesOk' = true :=
    all_opsIn_append (m := 600) (n := 100) rfl h5 footprintNamesTable'_600
  have h7 : (opsIn 0 800).all footprintNamesOk' = true :=
    all_opsIn_append (m := 700) (n := 100) rfl h6 footprintNamesTable'_700
  have h8 : (opsIn 0 900).all footprintNamesOk' = true :=
    all_opsIn_append (m := 800) (n := 100) rfl h7 footprintNamesTable'_800
  have h9 : (opsIn 0 905).all footprintNamesOk' = true :=
    all_opsIn_append (m := 900) (n := 5) rfl h8 footprintNamesTable'_900
  exact h9

theorem mem_all_of_handler {op : Full.Opcode} {hi : Handlers.HandlerInfo}
    (h : op.handler? = some hi) : op ∈ Full.all := by
  have hlt : op.val.toNat < Full.count := by
    refine Classical.byContradiction fun hn => ?_
    have hsz : Handlers.handlers.size = Full.count := by decide +kernel
    unfold Full.Opcode.handler? at h
    rw [getElem!_neg Handlers.handlers op.val.toNat (by omega)] at h
    cases h
  unfold Full.all
  refine List.mem_map.2 ⟨op.val.toNat, List.mem_range.2 hlt, ?_⟩
  cases op; simp

theorem footprintNamesTable : Full.all.all footprintNamesOk = true := by
  have h' := List.all_eq_true.1 footprintNamesTable'
  refine List.all_eq_true.2 fun op hop => ?_
  have h1 := h' op hop
  unfold footprintNamesOk' at h1
  unfold footprintNamesOk OpSem.footprint
  cases hh : op.handler? with
  | none => rfl
  | some hi =>
    simp only [Option.bind]
    cases hf : OpSem.footprintOf hi.kind hi.params with
    | none => rfl
    | some fp =>
      obtain ⟨hn, ha⟩ := footprintOf_names hf
      have hl := List.all_eq_true.1 (footprintOf_lenExt hf)
      simp only [hh, namesOk, Bool.and_eq_true] at h1
      obtain ⟨⟨hnd, hL⟩, hA⟩ := h1
      have hL' := List.all_eq_true.1 hL
      simp only [Bool.and_eq_true]
      refine ⟨⟨hnd, List.all_eq_true.2 fun a ha' => ?_⟩, by rw [ha]; exact hA⟩
      have hm : (a.opnd, extentNames a.extent) ∈ namesOf hi.kind := by
        rw [← hn]; exact List.mem_map_of_mem ha'
      have h2 := hL' _ hm
      simp only [Bool.and_eq_true] at h2 ⊢
      exact ⟨⟨h2.1, h2.2⟩, hl a ha'⟩

/-- What `opndRanges` reads covers stays covered. -/
theorem opndStep_keep (f : Nat) (isCall : Bool) (eb : Nat) {i : Nat} (hi : i < f)
    (st : Frame.Ranges × Frame.Ranges) (x : BitVec 32 × Frame.Access)
    (h : (Frame.Ranges.bits st.1).testBit i = true) :
    (Frame.Ranges.bits (Frame.Flow.opndStep f isCall eb st x).1).testBit i = true := by
  have hall : (Frame.Ranges.bits [((0 : Nat), f)]).testBit i = true := by
    rw [testBit_rangesBits]
    simp [hi]
  obtain ⟨xo, acc⟩ := x
  cases acc with
  | read m =>
    simp only [Frame.Flow.opndStep]
    rw [testBit_rangesBits] at h ⊢
    simp only [List.any_cons, Bool.or_eq_true]
    exact .inr h
  | «opaque» =>
    simp only [Frame.Flow.opndStep]
    exact hall
  | addr =>
    simp only [Frame.Flow.opndStep]
    split
    · exact hall
    · exact h
  | write m =>
    simp only [Frame.Flow.opndStep]
    exact h
  | clobber m =>
    simp only [Frame.Flow.opndStep]
    exact h

/-- A `read` access's range is among `opndRanges`' reads (or the whole frame). -/
theorem opndRanges_read_cover (f : Nat) (isCall : Bool) (eb : Nat) {i : Nat} (hi : i < f) :
    ∀ (L : List (BitVec 32 × Frame.Access)) (st : Frame.Ranges × Frame.Ranges),
      ((Frame.Ranges.bits st.1).testBit i = true ∨ ∃ x ∈ L, ∃ m, x.2 = .read m ∧
        (Frame.range f x.1 m).1 ≤ i ∧ i < (Frame.range f x.1 m).2) →
      (Frame.Ranges.bits (L.foldl (Frame.Flow.opndStep f isCall eb) st).1).testBit i = true
  | [], st, h => by
    rcases h with h | ⟨_, hx, _⟩
    · exact h
    · cases hx
  | x :: L, st, h => by
    simp only [List.foldl_cons]
    apply opndRanges_read_cover f isCall eb hi L
    rcases h with h | ⟨y, hy, m, hm, h1, h2⟩
    · exact .inl (opndStep_keep f isCall eb hi st x h)
    · rcases List.mem_cons.1 hy with hyx | hy
      · subst hyx
        left
        obtain ⟨yo, acc⟩ := y
        try simp only at hm
        subst hm
        simp only [Frame.Flow.opndStep]
        rw [testBit_rangesBits]
        simp only [List.any_cons, Bool.or_eq_true, Bool.and_eq_true, decide_eq_true_eq]
        exact .inl ⟨h1, h2⟩
      · exact .inr ⟨y, hy, m, hm, h1, h2⟩

/-! ### `Frame.opndVals` against `R.unpack` (DS-T8, piece 2) -/

/-- `Frame.handler`'s operand values (its `val`). -/
abbrev valH (h : Full.Opcode) (args : List R.Arg) (l : Asm.Layout) (n : String) :
    Option OpSem.Val :=
  ((Frame.opndVals h args l).find? (·.1 == n)).map (·.2)

/-- The bits `R.unpack`'s `narrow` keeps of a register. -/
def narrowOf (loc : Asm.Loc) (v : Nat) : Nat :=
  if loc.shared then (v >>> loc.shift) % 2 ^ 32 else v

/-- `Frame.opndVals`' value of an operand of kind `k` at `loc`, from register value `v`. -/
def frameVal (k : OperandKind) (loc : Asm.Loc) (v : BitVec 64) : Option OpSem.Val :=
  match k with
  | .slot => some (.slot (BitVec.ofNat 32 (v.toNat >>> (loc.shift / 32 * 32) % 2 ^ 32)).toInt)
  | .mem => some (.mem (BitVec.ofNat 32 (v.toNat >>> (loc.shift / 32 * 32) % 2 ^ 32)).toInt 0)
  | .u8 | .u16 | .u32 | .u64 | .i64 =>
    some (.imm (if loc.shared then (v.toNat >>> loc.shift) % 2 ^ 32 else v.toNat))
  | _ => none

theorem locs_getD (L : List Asm.Loc) (k : Nat) : L.getD k default = L[k]! := by
  by_cases hk : k < L.length
  · rw [getElem!_pos L k hk, List.getD_eq_getElem?_getD, List.getElem?_eq_getElem hk,
      Option.getD_some]
  · rw [getElem!_neg L k hk, List.getD_eq_getElem?_getD, List.getElem?_eq_none (by omega),
      Option.getD_none]

theorem bind_eq_some' {α β : Type} {x : Option α} {f : α → Option β} {b : β}
    (h : (x >>= f) = some b) : ∃ a, x = some a ∧ f a = some b := by
  cases x with
  | none => cases h
  | some a => exact ⟨a, rfl, h⟩

theorem mapM_some {α β : Type} {f : α → Option β} :
    ∀ {l : List α} {bs : List β}, l.mapM f = some bs →
      bs.length = l.length ∧ ∀ i (h1 : i < l.length) (h2 : i < bs.length), f l[i] = some bs[i]
  | [], bs, h => by cases h; simp
  | x :: l, bs, h => by
    simp only [List.mapM_cons, bind, Option.bind_eq_some_iff, pure, Option.some.injEq] at h
    obtain ⟨b, hb, bs', hbs, rfl⟩ := h
    obtain ⟨hlen, hall⟩ := mapM_some hbs
    refine ⟨by simp [hlen], fun i h1 h2 => ?_⟩
    cases i with
    | zero => exact hb
    | succ i => exact hall i (by simpa using h1) (by simpa using h2)

/-- A `mapM` whose function agrees with `g` where both are `some` on every element. -/
theorem mapM_agree {α β : Type} {f g : α → Option β} :
    ∀ (L : List α), (∀ a ∈ L, ∃ r, f a = some r ∧ g a = some r) →
      L.mapM f = some (L.filterMap g)
  | [], _ => rfl
  | a :: L, h => by
    obtain ⟨r, h1, h2⟩ := h a List.mem_cons_self
    rw [List.mapM_cons, h1, mapM_agree L (fun b hb => h b (List.mem_cons_of_mem _ hb)),
      List.filterMap_cons_some h2]
    rfl

/-- The operand named `L[k].name` among `filterMap F` of the indexed operands, when `F` keeps
names and they are distinct. -/
theorem find_filterMap_zipIdx (F : OperandInfo × Nat → Option (String × OpSem.Val))
    (hF : ∀ x y, F x = some y → y.1 = x.1.name) :
    ∀ (L : List OperandInfo) (n : Nat), (L.map (·.name)).Nodup → ∀ k (hk : k < L.length) y,
      F (L[k], n + k) = some y → ((L.zipIdx n).filterMap F).find? (·.1 == L[k].name) = some y
  | [], _, _, k, hk, _, _ => absurd hk (by simp)
  | a :: L, n, _, 0, _, y, hy => by
    have hy' : F (a, n) = some y := hy
    have hy1 : y.1 = a.name := hF _ y hy'
    show (((a :: L).zipIdx n).filterMap F).find? (·.1 == a.name) = some y
    rw [List.zipIdx_cons, List.filterMap_cons_some hy',
      List.find?_cons_of_pos (p := fun x : String × OpSem.Val => x.1 == a.name) (a := y)
        (by simp [hy1])]
  | a :: L, n, hnd, k + 1, hk, y, hy => by
    rw [List.map_cons, List.nodup_cons] at hnd
    have hk' : k < L.length := by simpa using hk
    have hne : a.name ≠ L[k].name := fun he =>
      hnd.1 (List.mem_map.2 ⟨L[k], List.getElem_mem hk', he.symm⟩)
    have hy' : F (L[k], (n + 1) + k) = some y := by
      rw [show n + 1 + k = n + (k + 1) by omega]; exact hy
    show (((a :: L).zipIdx n).filterMap F).find? (·.1 == L[k].name) = some y
    rw [List.zipIdx_cons]
    cases hb : F (a, n) with
    | none =>
      rw [List.filterMap_cons_none hb]
      exact find_filterMap_zipIdx F hF L (n + 1) hnd.2 k hk' y hy'
    | some z =>
      have hz1 : z.1 = a.name := hF _ z hb
      rw [List.filterMap_cons_some hb,
        List.find?_cons_of_neg (p := fun x : String × OpSem.Val => x.1 == L[k].name) (a := z)
          (by simp [hz1, hne])]
      exact find_filterMap_zipIdx F hF L (n + 1) hnd.2 k hk' y hy'

/-- `opndVal`'s lookup by a distinct name. -/
theorem find_zip_idx : ∀ (L : List OperandInfo) (M : List OpSem.Val), (L.map (·.name)).Nodup →
    ∀ k (hk : k < L.length) (hm : k < M.length),
      (L.zip M).find? (·.1.name == L[k].name) = some (L[k], M[k])
  | [], _, _, k, hk, _ => absurd hk (by simp)
  | _ :: _, [], _, k, _, hm => absurd hm (by simp)
  | a :: L, v :: M, _, 0, _, _ => by
    show ((a :: L).zip (v :: M)).find? (·.1.name == a.name) = some (a, v)
    rw [List.zip_cons_cons,
      List.find?_cons_of_pos (p := fun q : OperandInfo × OpSem.Val => q.1.name == a.name)
        (a := (a, v)) (by simp)]
  | a :: L, v :: M, hnd, k + 1, hk, hm => by
    rw [List.map_cons, List.nodup_cons] at hnd
    have hk' : k < L.length := by simpa using hk
    have hm' : k < M.length := by simpa using hm
    have hne : a.name ≠ L[k].name := fun he =>
      hnd.1 (List.mem_map.2 ⟨L[k], List.getElem_mem hk', he.symm⟩)
    show ((a :: L).zip (v :: M)).find? (·.1.name == L[k].name) = some (L[k], M[k])
    rw [List.zip_cons_cons,
      List.find?_cons_of_neg (p := fun q : OperandInfo × OpSem.Val => q.1.name == L[k].name)
        (a := (a, v)) (by simp [hne])]
    exact find_zip_idx L M hnd.2 k hk' hm'

/-- What `R.unpack` succeeding says: a layout, the register count, and each operand's
`unpackOpnd`. -/
theorem unpack_parts {ρ : R.Addrs} {h : Full.Opcode} {mode : Ryo.Obj.Mode} {args : List R.Arg}
    {vals : OpSem.Operands} (hu : R.unpack ρ h mode args = some vals) :
    ∃ l, h.layout mode.fpArg mode.pe = some l ∧ args.length = l.regs ∧
      h.info.operands.zipIdx.mapM
        (fun x => R.unpackOpnd ρ args x.1.kind (l.locs.getD x.2 default)) = some vals := by
  unfold R.unpack at hu
  revert hu
  cases hl : h.layout mode.fpArg mode.pe with
  | none => intro hu; cases hu
  | some l =>
    intro hu
    simp only [Option.bind_some, bind] at hu
    by_cases h1 : (args.length != l.regs) = true
    · simp [h1] at hu
    · by_cases h2 : (mode.fpArg && args[0]? != some .fp) = true
      · simp [h2] at hu
      · by_cases h3 : (h.info.shape == .lpad && args[l.first - 1]? != some .exception) = true
        · simp [h3] at hu
        · simp only [h1, h2, h3, Bool.false_eq_true, ↓reduceIte] at hu
          exact ⟨l, rfl, by simpa using h1, hu⟩

set_option maxRecDepth 20000 in
theorem layoutAgree_of {op : Full.Opcode} (hop : layoutAgreeOk op = true) {fa pe : Bool}
    {l : Asm.Layout} (hl : op.layout fa pe = some l) {k : Nat}
    (hk : k < op.info.operands.length) :
    locAgreeOk op.info.operands[k] (l.locs.getD k default) = true := by
  unfold layoutAgreeOk at hop
  have hmem : (fa, pe) ∈ [(false, false), (true, false), (false, true), (true, true)] := by
    cases fa <;> cases pe <;> simp
  have h1 := List.all_eq_true.1 hop _ hmem
  simp only [hl] at h1
  have hz : (op.info.operands[k], k) ∈ op.info.operands.zipIdx := by
    have := List.getElem_mem (l := op.info.operands.zipIdx) (n := k) (by simpa using hk)
    rw [List.getElem_zipIdx, Nat.zero_add] at this
    exact this
  exact List.all_eq_true.1 h1 _ hz

/-- A shared slot or memory operand is at a multiple of 32 bits, else in the low 32: the word
`opndVals` takes is `unpack`'s narrowed value. -/
theorem word_eq {o : OperandInfo} {loc : Asm.Loc} (h : locAgreeOk o loc = true)
    (h0 : loc.count ≠ 0) (hk : o.kind = .slot ∨ o.kind = .mem) {v : Nat}
    (hb : narrowOf loc v < 2 ^ 32) : v >>> (loc.shift / 32 * 32) % 2 ^ 32 = narrowOf loc v := by
  have h' : (if loc.shared then loc.shift % 32 == 0 else decide (loc.shift < 32)) = true := by
    unfold locAgreeOk at h
    have h0' : (loc.count == 0) = false := by simpa using h0
    rw [h0', Bool.false_or] at h
    rcases hk with hk | hk <;> rw [hk] at h <;> exact h
  unfold narrowOf at hb ⊢
  cases hs : loc.shared
  · rw [hs, if_neg Bool.false_ne_true] at h' hb
    rw [if_neg Bool.false_ne_true]
    have h2 : loc.shift < 32 := of_decide_eq_true h'
    have e : loc.shift / 32 * 32 = 0 := by omega
    rw [e, Nat.shiftRight_zero, Nat.mod_eq_of_lt hb]
  · rw [hs, if_pos rfl] at h'
    rw [if_pos rfl]
    have h2 : loc.shift % 32 = 0 := by simpa using h'
    have e : loc.shift / 32 * 32 = loc.shift := by omega
    rw [e]

/-- A 64-bit immediate isn't shared. -/
theorem locAgree_big {o : OperandInfo} {loc : Asm.Loc} (h : locAgreeOk o loc = true)
    (h0 : loc.count ≠ 0) (hk : o.kind = .u64 ∨ o.kind = .i64) : loc.shared = false := by
  unfold locAgreeOk at h
  have h0' : (loc.count == 0) = false := by simpa using h0
  rw [h0', Bool.false_or] at h
  rcases hk with hk | hk <;> rw [hk] at h <;> simpa using h

/-- A slot, memory or immediate operand `unpack` reads is in a register holding an
immediate. -/
theorem unpack_reg {ρ : R.Addrs} {args : List R.Arg} {k : OperandKind} {loc : Asm.Loc}
    {x : OpSem.Val} (hx : R.unpackOpnd ρ args k loc = some x)
    (hk : isFrameKind k = true ∨ isImmKind k = true) :
    loc.count ≠ 0 ∧ ∃ v : BitVec 64, args[loc.reg]? = some (.imm v) := by
  unfold R.unpackOpnd R.regImm at hx
  try dsimp only at hx
  by_cases h0 : (loc.count == 0) = true
  · rw [if_pos h0] at hx
    rcases hk with hk | hk <;> cases k <;> simp [isFrameKind, isImmKind] at hk <;> cases hx
  · rw [if_neg h0] at hx
    refine ⟨by simpa using h0, ?_⟩
    cases ha : args[loc.reg]? with
    | none =>
      rw [ha] at hx
      rcases hk with hk | hk <;> cases k <;> simp [isFrameKind, isImmKind] at hk <;> cases hx
    | some a =>
      cases a with
      | imm v => exact ⟨v, rfl⟩
      | _ =>
        rw [ha] at hx
        rcases hk with hk | hk <;> cases k <;> simp [isFrameKind, isImmKind] at hk <;> cases hx

theorem unpack_slot {ρ : R.Addrs} {args : List R.Arg} {loc : Asm.Loc} {x : OpSem.Val}
    (hx : R.unpackOpnd ρ args .slot loc = some x) (h0 : loc.count ≠ 0) {v : BitVec 64}
    (ha : args[loc.reg]? = some (.imm v)) :
    narrowOf loc v.toNat < 2 ^ 32 ∧ x = .slot (int32 (narrowOf loc v.toNat)) := by
  have h0' : ¬ ((loc.count == 0) = true) := by simpa using h0
  unfold R.unpackOpnd R.regImm at hx
  try dsimp only at hx
  rw [if_neg h0', ha] at hx
  obtain ⟨p, hp, hx⟩ := bind_eq_some' hx
  have hp' : (if narrowOf loc v.toNat < 2 ^ 32 then some (narrowOf loc v.toNat) else none) =
      some p := hp
  split at hp'
  next hb =>
    cases hp'
    cases hx
    exact ⟨hb, rfl⟩
  next => cases hp'

theorem unpack_mem {ρ : R.Addrs} {args : List R.Arg} {loc : Asm.Loc} {x : OpSem.Val}
    (hx : R.unpackOpnd ρ args .mem loc = some x) (h0 : loc.count ≠ 0) {v : BitVec 64}
    (ha : args[loc.reg]? = some (.imm v)) :
    narrowOf loc v.toNat < 2 ^ 32 ∧ ∃ q, x = .mem (int32 (narrowOf loc v.toNat)) q := by
  have h0' : ¬ ((loc.count == 0) = true) := by simpa using h0
  unfold R.unpackOpnd R.regImm at hx
  try dsimp only at hx
  rw [if_neg h0', ha] at hx
  obtain ⟨p, hp, hx⟩ := bind_eq_some' hx
  have hp' : (if narrowOf loc v.toNat < 2 ^ 32 then some (narrowOf loc v.toNat) else none) =
      some p := hp
  split at hp'
  next hb =>
    cases hp'
    obtain ⟨y, -, hx⟩ := bind_eq_some' hx
    refine ⟨hb, ?_⟩
    try dsimp only at hx
    split at hx <;> cases hx <;> exact ⟨_, rfl⟩
  next => cases hp'

theorem unpack_small {ρ : R.Addrs} {args : List R.Arg} {k : OperandKind} {loc : Asm.Loc}
    {x : OpSem.Val} (hx : R.unpackOpnd ρ args k loc = some x)
    (hk : k = .u8 ∨ k = .u16 ∨ k = .u32) (h0 : loc.count ≠ 0) {v : BitVec 64}
    (ha : args[loc.reg]? = some (.imm v)) : x = .imm (narrowOf loc v.toNat) := by
  have h0' : ¬ ((loc.count == 0) = true) := by simpa using h0
  unfold R.unpackOpnd R.regImm at hx
  try dsimp only at hx
  rw [if_neg h0', ha] at hx
  rcases hk with rfl | rfl | rfl
  · obtain ⟨p, hp, hx⟩ := bind_eq_some' hx
    have hp' : (if narrowOf loc v.toNat < 2 ^ 8 then some (narrowOf loc v.toNat) else none) =
        some p := hp
    split at hp' <;> cases hp'
    cases hx; rfl
  · obtain ⟨p, hp, hx⟩ := bind_eq_some' hx
    have hp' : (if narrowOf loc v.toNat < 2 ^ 16 then some (narrowOf loc v.toNat) else none) =
        some p := hp
    split at hp' <;> cases hp'
    cases hx; rfl
  · obtain ⟨p, hp, hx⟩ := bind_eq_some' hx
    have hp' : (if narrowOf loc v.toNat < 2 ^ 32 then some (narrowOf loc v.toNat) else none) =
        some p := hp
    split at hp' <;> cases hp'
    cases hx; rfl

theorem unpack_big {ρ : R.Addrs} {args : List R.Arg} {k : OperandKind} {loc : Asm.Loc}
    {x : OpSem.Val} (hx : R.unpackOpnd ρ args k loc = some x) (hk : k = .u64 ∨ k = .i64)
    (h0 : loc.count ≠ 0) {v : BitVec 64} (ha : args[loc.reg]? = some (.imm v)) :
    x = .imm v.toNat := by
  have h0' : ¬ ((loc.count == 0) = true) := by simpa using h0
  unfold R.unpackOpnd R.regImm at hx
  try dsimp only at hx
  rw [if_neg h0', ha] at hx
  rcases hk with rfl | rfl <;> (cases hx; rfl)

set_option maxRecDepth 20000 in
/-- `Frame.opndVals`' value of operand `k` (its names distinct). -/
theorem valH_eq {h : Full.Opcode} {args : List R.Arg} {l : Asm.Layout}
    (hnd : (h.info.operands.map (·.name)).Nodup) {k : Nat} (hk : k < h.info.operands.length)
    {v : BitVec 64} (hc : ¬ ((l.locs.getD k default).count == 0) = true)
    (ha : args[(l.locs.getD k default).reg]? = some (.imm v))
    (hs : (frameVal h.info.operands[k].kind (l.locs.getD k default) v).isSome) :
    valH h args l h.info.operands[k].name =
      frameVal h.info.operands[k].kind (l.locs.getD k default) v := by
  obtain ⟨y, hy⟩ := Option.isSome_iff_exists.1 hs
  rw [hy]
  rw [locs_getD] at hc ha hy
  have hf : (Frame.opndVals h args l).find? (·.1 == h.info.operands[k].name) =
      some (h.info.operands[k].name, y) := by
    unfold Frame.opndVals
    refine find_filterMap_zipIdx _ ?_ _ 0 hnd k hk _ ?_
    · rintro ⟨o, j⟩ z hz
      try dsimp only at hz
      by_cases hc' : ((l.locs[j]!).count == 0) = true
      · rw [if_pos hc'] at hz; cases hz
      · rw [if_neg hc'] at hz
        revert hz
        cases ha' : args[(l.locs[j]!).reg]? with
        | none => intro hz; cases hz
        | some a =>
          cases a with
          | imm w => cases ho : o.kind <;> intro hz <;> cases hz <;> rfl
          | _ => intro hz; cases hz
    · rw [Nat.zero_add]
      try dsimp only
      rw [if_neg hc, ha]
      revert hy
      cases ho : h.info.operands[k].kind <;> intro hy <;> cases hy <;> rfl
  exact (congrArg (Option.map (·.2)) hf).trans rfl

set_option maxRecDepth 20000 in
/-- Operand `k`'s `unpack`: its value and `opndVal`'s. -/
theorem opnd_ctx {ρ : R.Addrs} {h : Full.Opcode} {args : List R.Arg} {l : Asm.Layout}
    {vals : OpSem.Operands}
    (hmap : h.info.operands.zipIdx.mapM
      (fun x => R.unpackOpnd ρ args x.1.kind (l.locs.getD x.2 default)) = some vals)
    (hnd : (h.info.operands.map (·.name)).Nodup) {k : Nat} (hk : k < h.info.operands.length) :
    ∃ hkv : k < vals.length,
      R.unpackOpnd ρ args h.info.operands[k].kind (l.locs.getD k default) = some vals[k] ∧
      OpSem.opndVal h.info vals h.info.operands[k].name = some vals[k] := by
  obtain ⟨hlen, hall⟩ := mapM_some hmap
  have hkz : k < h.info.operands.zipIdx.length := by simpa using hk
  have hkv : k < vals.length := by rw [hlen]; exact hkz
  refine ⟨hkv, ?_, ?_⟩
  · have hx := hall k hkz hkv
    rw [List.getElem_zipIdx, Nat.zero_add] at hx
    exact hx
  · exact (congrArg (Option.map (·.2)) (find_zip_idx _ _ hnd k hk hkv)).trans rfl

section Agree

variable {ρ : R.Addrs} {h : Full.Opcode} {mode : Ryo.Obj.Mode} {args : List R.Arg}
  {l : Asm.Layout} {vals : OpSem.Operands}

set_option maxRecDepth 20000 in
theorem opnd_frame (hl : h.layout mode.fpArg mode.pe = some l)
    (hmap : h.info.operands.zipIdx.mapM
      (fun x => R.unpackOpnd ρ args x.1.kind (l.locs.getD x.2 default)) = some vals)
    (hlay : layoutAgreeOk h = true) (hnd : (h.info.operands.map (·.name)).Nodup) {k : Nat}
    (hk : k < h.info.operands.length) (hfk : isFrameKind h.info.operands[k].kind = true) :
    ∃ b : BitVec 32, (valH h args l h.info.operands[k].name).bind OpSem.Val.slotOff =
        some b.toInt ∧
      (OpSem.opndVal h.info vals h.info.operands[k].name).bind OpSem.Val.slotOff =
        some b.toInt := by
  obtain ⟨hkv, hx, hU⟩ := opnd_ctx hmap hnd hk
  have hfk' : h.info.operands[k].kind = .slot ∨ h.info.operands[k].kind = .mem := by
    revert hfk; cases h.info.operands[k].kind <;> simp [isFrameKind]
  obtain ⟨h0, v, ha⟩ := unpack_reg hx (.inl hfk)
  have h0' : ¬ ((l.locs.getD k default).count == 0) = true := by simpa using h0
  have hag := layoutAgree_of hlay hl hk
  rw [hU]
  generalize vals[k] = vk at hx ⊢
  rcases hfk' with hs | hs
  · rw [hs] at hx
    obtain ⟨hb, rfl⟩ := unpack_slot hx h0 ha
    have hw := word_eq hag h0 (.inl hs) hb
    refine ⟨BitVec.ofNat 32 (narrowOf (l.locs.getD k default) v.toNat), ?_, rfl⟩
    rw [valH_eq hnd hk h0' ha (by rw [hs] <;> rfl), hs]
    show some (BitVec.ofNat 32 _).toInt = _
    rw [hw]
  · rw [hs] at hx
    obtain ⟨hb, q, rfl⟩ := unpack_mem hx h0 ha
    have hw := word_eq hag h0 (.inr hs) hb
    refine ⟨BitVec.ofNat 32 (narrowOf (l.locs.getD k default) v.toNat), ?_, rfl⟩
    rw [valH_eq hnd hk h0' ha (by rw [hs] <;> rfl), hs]
    show some (BitVec.ofNat 32 _).toInt = _
    rw [hw]

set_option maxRecDepth 20000 in
theorem opnd_imm (hl : h.layout mode.fpArg mode.pe = some l)
    (hmap : h.info.operands.zipIdx.mapM
      (fun x => R.unpackOpnd ρ args x.1.kind (l.locs.getD x.2 default)) = some vals)
    (hlay : layoutAgreeOk h = true) (hnd : (h.info.operands.map (·.name)).Nodup) {k : Nat}
    (hk : k < h.info.operands.length) (hik : isImmKind h.info.operands[k].kind = true) :
    ∃ x, valH h args l h.info.operands[k].name = some (.imm x) ∧
      OpSem.opndVal h.info vals h.info.operands[k].name = some (.imm x) := by
  obtain ⟨hkv, hx, hU⟩ := opnd_ctx hmap hnd hk
  obtain ⟨h0, v, ha⟩ := unpack_reg hx (.inr hik)
  have h0' : ¬ ((l.locs.getD k default).count == 0) = true := by simpa using h0
  have hag := layoutAgree_of hlay hl hk
  have hcases : h.info.operands[k].kind = .u8 ∨ h.info.operands[k].kind = .u16 ∨
      h.info.operands[k].kind = .u32 ∨ h.info.operands[k].kind = .u64 ∨
      h.info.operands[k].kind = .i64 := by
    revert hik; cases h.info.operands[k].kind <;> simp [isImmKind]
  rw [hU]
  generalize vals[k] = vk at hx ⊢
  refine ⟨narrowOf (l.locs.getD k default) v.toNat, ?_, ?_⟩
  · have hsome : (frameVal h.info.operands[k].kind (l.locs.getD k default) v).isSome := by
      rcases hcases with hs | hs | hs | hs | hs <;> (rw [hs] <;> rfl)
    rw [valH_eq hnd hk h0' ha hsome]
    rcases hcases with hs | hs | hs | hs | hs
    · rw [hs] <;> rfl
    · rw [hs] <;> rfl
    · rw [hs] <;> rfl
    · rw [hs] <;> rfl
    · rw [hs] <;> rfl
  · rcases hcases with hs | hs | hs | hs | hs
    · rw [hs] at hx; exact congrArg some (unpack_small hx (.inl rfl) h0 ha)
    · rw [hs] at hx; exact congrArg some (unpack_small hx (.inr (.inl rfl)) h0 ha)
    · rw [hs] at hx; exact congrArg some (unpack_small hx (.inr (.inr rfl)) h0 ha)
    · have hsh := locAgree_big hag h0 (.inl hs)
      rw [hs] at hx
      rw [unpack_big hx (.inl rfl) h0 ha]
      unfold narrowOf
      simp only [hsh, Bool.false_eq_true, ↓reduceIte]
    · have hsh := locAgree_big hag h0 (.inr hs)
      rw [hs] at hx
      rw [unpack_big hx (.inr rfl) h0 ha]
      unfold narrowOf
      simp only [hsh, Bool.false_eq_true, ↓reduceIte]

theorem named_frame (hl : h.layout mode.fpArg mode.pe = some l)
    (hmap : h.info.operands.zipIdx.mapM
      (fun x => R.unpackOpnd ρ args x.1.kind (l.locs.getD x.2 default)) = some vals)
    (hlay : layoutAgreeOk h = true) (hnd : (h.info.operands.map (·.name)).Nodup) {n : String}
    (hn : namedKind h n isFrameKind = true) :
    ∃ b : BitVec 32, (valH h args l n).bind OpSem.Val.slotOff = some b.toInt ∧
      (OpSem.opndVal h.info vals n).bind OpSem.Val.slotOff = some b.toInt := by
  obtain ⟨o, hmem, hc⟩ := List.any_eq_true.1 hn
  obtain ⟨k, hk, rfl⟩ := List.getElem_of_mem hmem
  simp only [Bool.and_eq_true, beq_iff_eq] at hc
  obtain ⟨rfl, hc⟩ := hc
  exact opnd_frame hl hmap hlay hnd hk hc

theorem named_imm (hl : h.layout mode.fpArg mode.pe = some l)
    (hmap : h.info.operands.zipIdx.mapM
      (fun x => R.unpackOpnd ρ args x.1.kind (l.locs.getD x.2 default)) = some vals)
    (hlay : layoutAgreeOk h = true) (hnd : (h.info.operands.map (·.name)).Nodup) {n : String}
    (hn : namedKind h n isImmKind = true) :
    ∃ x, valH h args l n = some (.imm x) ∧ OpSem.opndVal h.info vals n = some (.imm x) := by
  obtain ⟨o, hmem, hc⟩ := List.any_eq_true.1 hn
  obtain ⟨k, hk, rfl⟩ := List.getElem_of_mem hmem
  simp only [Bool.and_eq_true, beq_iff_eq] at hc
  obtain ⟨rfl, hc⟩ := hc
  exact opnd_imm hl hmap hlay hnd hk hc

theorem range_of {val : String → Option OpSem.Val} {a : OpSem.Access} {o : Int} {m : Nat}
    (h1 : (val a.opnd).bind OpSem.Val.slotOff = some o) (h2 : a.extent.eval val = some m) :
    a.range val = some (o, m) := by
  unfold OpSem.Access.range
  rw [h1, h2] <;> rfl

/-- A footprint access whose names `footprintNamesOk` checks has the same range from
`Frame.opndVals` as from `unpack`, at the `toInt` of a 32-bit offset. -/
theorem access_agree (hl : h.layout mode.fpArg mode.pe = some l)
    (hmap : h.info.operands.zipIdx.mapM
      (fun x => R.unpackOpnd ρ args x.1.kind (l.locs.getD x.2 default)) = some vals)
    (hlay : layoutAgreeOk h = true) (hnd : (h.info.operands.map (·.name)).Nodup)
    {a : OpSem.Access}
    (ha : namedKind h a.opnd isFrameKind = true ∧
      (extentNames a.extent).all (fun n => namedKind h n isImmKind) = true ∧
      lenExt a.extent = true) :
    ∃ r, a.range (valH h args l) = some r ∧ a.range (OpSem.opndVal h.info vals) = some r ∧
      ∃ b : BitVec 32, r.1 = b.toInt := by
  obtain ⟨h1, h2, h3⟩ := ha
  obtain ⟨b, hb1, hb2⟩ := named_frame hl hmap hlay hnd h1
  have hext : ∃ m, a.extent.eval (valH h args l) = some m ∧
      a.extent.eval (OpSem.opndVal h.info vals) = some m := by
    revert h2 h3
    cases a.extent with
    | bytes m => intro _ _; exact ⟨m, rfl, rfl⟩
    | opnd x =>
      intro h2 _
      simp only [extentNames, List.all_cons, List.all_nil, Bool.and_true] at h2
      obtain ⟨y, hy1, hy2⟩ := named_imm hl hmap hlay hnd h2
      exact ⟨y, by simp only [OpSem.Extent.eval, hy1], by simp only [OpSem.Extent.eval, hy2]⟩
    | mul x z =>
      intro h2 _
      simp only [extentNames, List.all_cons, List.all_nil, Bool.and_true,
        Bool.and_eq_true] at h2
      obtain ⟨y, hy1, hy2⟩ := named_imm hl hmap hlay hnd h2.1
      obtain ⟨w, hw1, hw2⟩ := named_imm hl hmap hlay hnd h2.2
      exact ⟨y * w, by simp only [OpSem.Extent.eval, hy1, hw1],
        by simp only [OpSem.Extent.eval, hy2, hw2]⟩
    | slotVal _ => intro _ h3; cases h3
    | cases _ _ => intro _ h3; cases h3
  obtain ⟨m, hm1, hm2⟩ := hext
  exact ⟨(b.toInt, m), range_of hb1 hm1, range_of hb2 hm2, b, rfl⟩

end Agree

/-! ### `Frame.handler`'s exact branch (DS-T8, piece 3) -/

/-- When every footprint access evaluates, `Frame.handler` takes its exact branch. -/
theorem handler_exact {h : Full.Opcode} {args : List R.Arg} {mode : Ryo.Obj.Mode}
    {l : Asm.Layout} {e : Frame.Effects} (hl : h.layout mode.fpArg mode.pe = some l)
    (hlen : args.length = l.regs) {fp : OpSem.Footprint}
    (hfp : (if h == Full.Opcode.resume then
      some ({ reads := [⟨"x", .bytes 8⟩], flow := .trap } : OpSem.Footprint)
      else OpSem.footprint h) = some fp)
    {rs ws : List (Int × Nat)} {as : List Int}
    (hrs : fp.reads.mapM (·.range (valH h args l)) = some rs)
    (hws : fp.writes.mapM (·.range (valH h args l)) = some ws)
    (has : fp.addrs.mapM (fun n => (valH h args l n).bind OpSem.Val.slotOff) = some as)
    (he : Frame.handler h args mode = .ok e) :
    e.opnds = rs.map (fun (o, n) => (BitVec.ofInt 32 o, Frame.Access.read (min n (2 ^ 32 - 1)))) ++
      ws.map (fun (o, n) => (BitVec.ofInt 32 o, Frame.Access.write (min n (2 ^ 32 - 1)))) ++
      as.map (fun o => (BitVec.ofInt 32 o, Frame.Access.addr)) := by
  simp only [Option.bind] at has
  simp only [Frame.handler, hl, hlen, bne_self_eq_false, Bool.false_eq_true, ↓reduceIte, hfp,
    hrs, hws, has, bind, Option.bind, pure, Except.bind, Except.pure] at he
  repeat' split at he
  all_goals (cases he; rfl)

/-- The exact branch's operands, for a footprint whose names `footprintNamesOk` checks. -/
theorem exact_opnds {ρ : R.Addrs} {h : Full.Opcode} {mode : Ryo.Obj.Mode} {args : List R.Arg}
    {vals : OpSem.Operands} {e : Frame.Effects} (hu : R.unpack ρ h mode args = some vals)
    (he : Frame.handler h args mode = .ok e) {fp : OpSem.Footprint}
    (hfp : (if h == Full.Opcode.resume then
      some ({ reads := [⟨"x", .bytes 8⟩], flow := .trap } : OpSem.Footprint)
      else OpSem.footprint h) = some fp)
    (hlay : layoutAgreeOk h = true) (hnd : (h.info.operands.map (·.name)).Nodup)
    (hN1 : ∀ a ∈ fp.reads ++ fp.writes, namedKind h a.opnd isFrameKind = true ∧
      (extentNames a.extent).all (fun n => namedKind h n isImmKind) = true ∧
      lenExt a.extent = true)
    (hN2 : ∀ n ∈ fp.addrs, namedKind h n isFrameKind = true) :
    ∃ as : List Int,
      e.opnds = (fp.readRanges (OpSem.opndVal h.info vals)).map
          (fun (o, n) => (BitVec.ofInt 32 o, Frame.Access.read (min n (2 ^ 32 - 1)))) ++
        (fp.writeRanges (OpSem.opndVal h.info vals)).map
          (fun (o, n) => (BitVec.ofInt 32 o, Frame.Access.write (min n (2 ^ 32 - 1)))) ++
        as.map (fun o => (BitVec.ofInt 32 o, Frame.Access.addr)) ∧
      ∀ r ∈ fp.readRanges (OpSem.opndVal h.info vals) ++
        fp.writeRanges (OpSem.opndVal h.info vals), ∃ b : BitVec 32, r.1 = b.toInt := by
  obtain ⟨l, hl, hlen, hmap⟩ := unpack_parts hu
  have hacc : ∀ a ∈ fp.reads ++ fp.writes, ∃ r, a.range (valH h args l) = some r ∧
      a.range (OpSem.opndVal h.info vals) = some r ∧ ∃ b : BitVec 32, r.1 = b.toInt :=
    fun a ha => access_agree hl hmap hlay hnd (hN1 a ha)
  have hrs := mapM_agree (f := fun a : OpSem.Access => a.range (valH h args l))
    (g := fun a : OpSem.Access => a.range (OpSem.opndVal h.info vals)) fp.reads
    (fun a ha => let ⟨r, h1, h2, _⟩ := hacc a (List.mem_append_left _ ha); ⟨r, h1, h2⟩)
  have hws := mapM_agree (f := fun a : OpSem.Access => a.range (valH h args l))
    (g := fun a : OpSem.Access => a.range (OpSem.opndVal h.info vals)) fp.writes
    (fun a ha => let ⟨r, h1, h2, _⟩ := hacc a (List.mem_append_right _ ha); ⟨r, h1, h2⟩)
  have has := mapM_agree (f := fun n => (valH h args l n).bind OpSem.Val.slotOff)
    (g := fun n => (valH h args l n).bind OpSem.Val.slotOff) fp.addrs
    (fun n hn => let ⟨_, h1, _⟩ := named_frame hl hmap hlay hnd (hN2 n hn); ⟨_, h1, h1⟩)
  refine ⟨_, handler_exact hl hlen hfp hrs hws has he, ?_⟩
  intro r hr
  rcases List.mem_append.1 hr with hr | hr
  · obtain ⟨a, ha, har⟩ := List.mem_filterMap.1 hr
    obtain ⟨r', -, h2, b, hb⟩ := hacc a (List.mem_append_left _ ha)
    have har' : a.range (OpSem.opndVal h.info vals) = some r := har
    rw [h2] at har'
    cases har'
    exact ⟨b, hb⟩
  · obtain ⟨a, ha, har⟩ := List.mem_filterMap.1 hr
    obtain ⟨r', -, h2, b, hb⟩ := hacc a (List.mem_append_right _ ha)
    have har' : a.range (OpSem.opndVal h.info vals) = some r := har
    rw [h2] at har'
    cases har'
    exact ⟨b, hb⟩

/-- A `read` of `[o0, o0 + n)` (capped) among the operands covers its frame bytes. -/
theorem read_bit {F eb : Nat} {opnds : List (BitVec 32 × Frame.Access)} {o0 : Int} {n : Nat}
    (hmem : (BitVec.ofInt 32 o0, Frame.Access.read (min n (2 ^ 32 - 1))) ∈ opnds)
    {b : BitVec 32} (hb : o0 = b.toInt) {o : Int} (h1 : -(F : Int) ≤ o) (h2 : o < 0)
    (h3 : o0 ≤ o) (h4 : o < o0 + n) :
    (Frame.Ranges.bits (Frame.Flow.opndRanges F false eb opnds).1).testBit (o + F).toNat =
      true := by
  subst hb
  rw [BitVec.ofInt_toInt] at hmem
  have hlo : -2147483648 ≤ b.toInt := by have := BitVec.le_toInt b; simpa using this
  have hcap : n ≤ min n (2 ^ 32 - 1) ∨ min n (2 ^ 32 - 1) = 4294967295 := by
    rcases Nat.le_total n (2 ^ 32 - 1) with hn | hn
    · exact .inl (Nat.le_of_eq (Nat.min_eq_left hn).symm)
    · exact .inr (Nat.min_eq_right hn)
  generalize min n (2 ^ 32 - 1) = m at hmem hcap
  refine opndRanges_read_cover F false eb (i := (o + F).toNat) (by omega) opnds ([], []) ?_
  right
  refine ⟨_, hmem, m, rfl, ?_, ?_⟩ <;> simp only [Frame.range] <;> omega

/-- A sure write of the exact branch's operands is in a footprint write range. -/
theorem write_of_bit {F eb : Nat} {opnds : List (BitVec 32 × Frame.Access)}
    {rsR rsW : List (Int × Nat)} {as : List Int}
    (hop : opnds = rsR.map
        (fun (o, n) => (BitVec.ofInt 32 o, Frame.Access.read (min n (2 ^ 32 - 1)))) ++
      rsW.map (fun (o, n) => (BitVec.ofInt 32 o, Frame.Access.write (min n (2 ^ 32 - 1)))) ++
      as.map (fun o => (BitVec.ofInt 32 o, Frame.Access.addr)))
    (hb : ∀ r ∈ rsW, ∃ b : BitVec 32, r.1 = b.toInt) {o : Int} (h1 : -(F : Int) ≤ o)
    (h2 : o < 0)
    (hbit : (Frame.Ranges.bits (Frame.Flow.opndRanges F false eb opnds).2).testBit
      (o + F).toNat = true) :
    ∃ rg ∈ rsW, OpSem.inRange o rg = true := by
  rw [testBit_rangesBits] at hbit
  obtain ⟨r, hr, hc⟩ := List.any_eq_true.1 hbit
  obtain ⟨off, m, hmem, rfl⟩ := opndRanges_kill hr
  simp only [Bool.and_eq_true, decide_eq_true_eq] at hc
  rw [hop] at hmem
  rcases List.mem_append.1 hmem with hmem | hmem
  · rcases List.mem_append.1 hmem with hmem | hmem
    · obtain ⟨⟨o0, n⟩, -, he⟩ := List.mem_map.1 hmem
      cases he
    · obtain ⟨⟨w0, n⟩, hw, he⟩ := List.mem_map.1 hmem
      cases he
      obtain ⟨b, hb'⟩ := hb _ hw
      have hb'' : w0 = b.toInt := hb'
      subst hb''
      rw [BitVec.ofInt_toInt] at hc
      have hle : min n (2 ^ 32 - 1) ≤ n := Nat.min_le_left _ _
      generalize min n (2 ^ 32 - 1) = m at hc hle
      simp only [Frame.range] at hc
      refine ⟨(b.toInt, n), hw, ?_⟩
      simp only [OpSem.inRange, decide_eq_true_eq]
      omega
  · obtain ⟨o0, -, he⟩ := List.mem_map.1 hmem
    cases he

/-! ### Handlers: the footprint against the row (T3a, DS-T8) -/

set_option maxRecDepth 100000 in
/-- `Frame.handler`'s row (computed from `Frame.opndVals`, the argument registers read by
layout, through `BitVec.ofInt 32` and `cap`) covers what `opSem` reads by its footprint over
`R.unpack`'s values, and kills only bytes the footprint writes; `resume`'s slot read is in it
too. For `unpack … = some vals`, `opndVals` and `opndVal h.info vals` agree on every
slot/immediate operand a footprint access names (`layoutAgreeTable`, `footprintNamesTable`), so
the exact branch is taken; its offsets are `toInt`s of 32-bit words and lengths are capped
at `2^32 - 1`, which reaches past the frame. -/
theorem handlerVals_agree {mode : Ryo.Obj.Mode} {ρ : R.Addrs} {h : Full.Opcode}
    {args : List R.Arg} {vals : OpSem.Operands} {e : Frame.Effects} (F eb : Nat)
    (hu : R.unpack ρ h mode args = some vals) (he : Frame.handler h args mode = .ok e) :
    (∀ fp, OpSem.footprint h = some fp → ∀ o : Int, -(F : Int) ≤ o → o < 0 →
      (∃ rg ∈ fp.readRanges (OpSem.opndVal h.info vals), OpSem.inRange o rg = true) →
      (Frame.Ranges.bits (Frame.Flow.opndRanges F false eb e.opnds).1).testBit
        (o + F).toNat = true) ∧
    (∀ fp, OpSem.footprint h = some fp → ∀ o : Int, -(F : Int) ≤ o → o < 0 →
      (Frame.Ranges.bits (Frame.Flow.opndRanges F false eb e.opnds).2).testBit
        (o + F).toNat = true →
      ∃ rg ∈ fp.writeRanges (OpSem.opndVal h.info vals), OpSem.inRange o rg = true) ∧
    (h = .resume → ∀ x : Int, vals = [.slot x] → ∀ o : Int, -(F : Int) ≤ o → o < 0 →
      x ≤ o → o < x + 8 →
      (Frame.Ranges.bits (Frame.Flow.opndRanges F false eb e.opnds).1).testBit
        (o + F).toNat = true) := by
  by_cases hres : h = .resume
  · subst hres
    have hfp0 : OpSem.footprint Full.Opcode.resume = none := by decide +kernel
    refine ⟨?_, ?_, ?_⟩
    · intro fp hfp; rw [hfp0] at hfp; cases hfp
    · intro fp hfp; rw [hfp0] at hfp; cases hfp
    rintro - x rfl o h1 h2 h3 h4
    have hops : Full.Opcode.resume.info.operands = [⟨"x", .slot⟩] := by rfl
    have hN1 : ∀ a ∈ ({ reads := [⟨"x", .bytes 8⟩], flow := .trap } : OpSem.Footprint).reads ++
        ({ reads := [⟨"x", .bytes 8⟩], flow := .trap } : OpSem.Footprint).writes,
        namedKind .resume a.opnd isFrameKind = true ∧
        (extentNames a.extent).all (fun n => namedKind .resume n isImmKind) = true ∧
        lenExt a.extent = true := by
      intro a ha
      simp only [List.append_nil, List.mem_singleton] at ha
      subst ha
      refine ⟨?_, rfl, rfl⟩
      show Full.Opcode.resume.info.operands.any (fun o => o.name == "x" && isFrameKind o.kind) = true
      rw [hops]; simp [isFrameKind]
    obtain ⟨as, hop, hb⟩ := exact_opnds hu he (if_pos (beq_self_eq_true _))
      (by decide +kernel) (by rw [hops]; simp) hN1 (fun n hn => by simp at hn)
    have hU : OpSem.opndVal Full.Opcode.resume.info [.slot x] "x" = some (.slot x) := by
      simp [OpSem.opndVal, hops]
    have hr : (⟨"x", .bytes 8⟩ : OpSem.Access).range
        (OpSem.opndVal Full.Opcode.resume.info [.slot x]) = some (x, 8) :=
      range_of (by
        show (OpSem.opndVal Full.Opcode.resume.info [.slot x] "x").bind OpSem.Val.slotOff =
          some x
        rw [hU] <;> rfl) rfl
    have hrg : ((x, 8) : Int × Nat) ∈
        ({ reads := [⟨"x", .bytes 8⟩], flow := .trap } : OpSem.Footprint).readRanges
          (OpSem.opndVal Full.Opcode.resume.info [.slot x]) :=
      List.mem_filterMap.2 ⟨_, List.mem_cons_self, hr⟩
    obtain ⟨b, hb0⟩ := hb _ (List.mem_append_left _ hrg)
    have hb0' : x = b.toInt := hb0
    exact read_bit (o0 := x) (n := 8)
      (by
        rw [hop]
        exact List.mem_append_left _ (List.mem_append_left _ (List.mem_map_of_mem hrg)))
      hb0' h1 h2 h3 h4
  · have hq : ∀ fp, OpSem.footprint h = some fp → (if h == Full.Opcode.resume then
        some ({ reads := [⟨"x", .bytes 8⟩], flow := .trap } : OpSem.Footprint)
        else OpSem.footprint h) = some fp := fun fp hfp => by
      have hne : (h == Full.Opcode.resume) = false := by simp [hres]
      rw [hne, if_neg Bool.false_ne_true]; exact hfp
    have hpre : ∀ fp, OpSem.footprint h = some fp → ∃ as : List Int,
        e.opnds = (fp.readRanges (OpSem.opndVal h.info vals)).map
            (fun (o, n) => (BitVec.ofInt 32 o, Frame.Access.read (min n (2 ^ 32 - 1)))) ++
          (fp.writeRanges (OpSem.opndVal h.info vals)).map
            (fun (o, n) => (BitVec.ofInt 32 o, Frame.Access.write (min n (2 ^ 32 - 1)))) ++
          as.map (fun o => (BitVec.ofInt 32 o, Frame.Access.addr)) ∧
        ∀ r ∈ fp.readRanges (OpSem.opndVal h.info vals) ++
          fp.writeRanges (OpSem.opndVal h.info vals), ∃ b : BitVec 32, r.1 = b.toInt := by
      intro fp hfp
      have hfp' := hfp
      unfold OpSem.footprint at hfp'
      obtain ⟨hi, hhi⟩ : ∃ hi, h.handler? = some hi := by
        cases hh : h.handler? with
        | none => rw [hh] at hfp'; cases hfp'
        | some hi => exact ⟨hi, rfl⟩
      have hmemA := mem_all_of_handler hhi
      have hlay := List.all_eq_true.1 layoutAgreeTable h hmemA
      have hok := List.all_eq_true.1 footprintNamesTable h hmemA
      unfold footprintNamesOk at hok
      rw [hfp] at hok
      dsimp only at hok
      rw [Bool.and_eq_true, Bool.and_eq_true] at hok
      obtain ⟨⟨hnd, hA⟩, hB⟩ := hok
      refine exact_opnds hu he (hq fp hfp) hlay (of_decide_eq_true hnd) (fun a ha => ?_)
        (fun n hn => List.all_eq_true.1 hB n hn)
      have := List.all_eq_true.1 hA a ha
      rw [Bool.and_eq_true, Bool.and_eq_true] at this
      exact ⟨this.1.1, this.1.2, this.2⟩
    refine ⟨?_, ?_, fun h' => absurd h' hres⟩
    · rintro fp hfp o h1 h2 ⟨⟨o0, n⟩, hrg, hin⟩
      obtain ⟨as, hop, hb⟩ := hpre fp hfp
      obtain ⟨b, hb0⟩ := hb _ (List.mem_append_left _ hrg)
      have hb0' : o0 = b.toInt := hb0
      have hin' : o0 ≤ o ∧ o < o0 + n := of_decide_eq_true hin
      exact read_bit (o0 := o0) (n := n)
        (by
          rw [hop]
          exact List.mem_append_left _ (List.mem_append_left _ (List.mem_map_of_mem hrg)))
        hb0' h1 h2 hin'.1 hin'.2
    · intro fp hfp o h1 h2 hbit
      obtain ⟨as, hop, hb⟩ := hpre fp hfp
      exact write_of_bit hop (fun r hr => hb r (List.mem_append_right _ hr)) h1 h2 hbit

/-- A successful `opSem` has a footprint. -/
theorem opSem_fp {op : Full.Opcode} {ops : OpSem.Operands} {st : OpSem.State}
    {ch : OpSem.Choice} {r : OpSem.Control × OpSem.State} (h : OpSem.opSem op ops st ch = .ok r) :
    ∃ fp, OpSem.footprint op = some fp := by
  unfold OpSem.opSem at h
  cases hp : OpSem.prepare op ops with
  | error e => rw [hp] at h; cases h
  | ok x =>
    obtain ⟨hi, fp', val⟩ := x
    exact ⟨fp', (OpSem.prepare_ok hp).1⟩

/-! ### Private bytes through the scopes -/

theorem escape_private {u u' : R.RState} {off : Int} {size align : Nat}
    (h : R.escape u off size align = .ok u') {o : Int} (hn : u.st.escapedAt o = none)
    (hout : ¬ (off ≤ o ∧ o < off + size)) :
    u'.st.escapedAt o = none ∧ u'.st.frame o = u.st.frame o := by
  rcases Ryo.Proofs.Scope.escape_ok h with rfl | ⟨_, _, _, _, _, _, _, _, rfl⟩
  · exact ⟨hn, rfl⟩
  · refine ⟨?_, rfl⟩
    dsimp only
    simp only [OpSem.State.escapedAt, List.find?_append] at hn ⊢
    rw [hn]
    simp [hout]

theorem storageEnd_private {u u' : R.RState} {off : Int} {size : Nat}
    (h : R.storageEnd u off size = .ok u') {o : Int} (hn : u.st.escapedAt o = none) :
    u'.st.escapedAt o = none ∧ ((off ≤ o ∧ o < off + size) → u'.st.frame o = .uninit) ∧
      (¬ (off ≤ o ∧ o < off + size) → u'.st.frame o = u.st.frame o) := by
  obtain ⟨st', hw, rfl⟩ := Ryo.Proofs.Scope.storageEnd_ok h
  obtain ⟨_, -, -, hesc, hfrm⟩ := writeFrame_parts hw
  have hn1 : ({ u.st with
      mem := R.freeObjs u.st.mem
        (u.st.escaped.filter fun e => decide (off ≤ e.off ∧ e.off + e.size ≤ off + size)),
      escaped := u.st.escaped.filter
        (not ∘ fun e => decide (off ≤ e.off ∧ e.off + e.size ≤ off + size)) } :
        OpSem.State).escapedAt o = none := by
    unfold OpSem.State.escapedAt at hn ⊢
    exact Ryo.Proofs.Scope.find?_filter_of_none hn
  have hn' : st'.escapedAt o = none := by
    unfold OpSem.State.escapedAt; rw [hesc]; exact hn1
  refine ⟨hn', fun hin => ?_, fun hout => ?_⟩
  · show st'.frame o = .uninit
    rw [hfrm o]
    simp only [OpSem.State.privateIn, hn1, Option.isNone_none, Bool.and_true,
      List.length_replicate, hin, and_self, decide_true, ↓reduceIte]
    exact getD_replicate_uninit _ _
  · show st'.frame o = u.st.frame o
    rw [hfrm o]
    simp only [OpSem.State.privateIn, List.length_replicate, hout, decide_false,
      Bool.false_and, Bool.false_eq_true, ↓reduceIte]

/-- A byte private before the scopes, which no `Escape` among them covers, stays private, and
its frame field is `Uninit` after them if it was before or an `End` among them covers it. -/
theorem private_fold {o : Int} : ∀ (l : List R.Scope) {u u1 : R.RState},
    l.foldlM R.applyScope u = .ok u1 → u.st.escapedAt o = none →
    (∀ sc ∈ l, ∀ a, sc.kind = .escape a →
      ¬ (sc.frameOffset.toInt ≤ o ∧ o < sc.frameOffset.toInt + sc.size)) →
    (u.st.frame o = .uninit ∨ ∃ sc ∈ l, sc.kind = .end ∧ sc.frameOffset.toInt ≤ o ∧
      o < sc.frameOffset.toInt + sc.size) →
    u1.st.frame o = .uninit
  | [], u, u1, h, _, _, hq => by
    cases h
    rcases hq with hq | ⟨_, hsc, _⟩
    · exact hq
    · cases hsc
  | sc :: l, u, u1, h, hn, hesc, hq => by
    simp only [List.foldlM_cons, bind, Except.bind] at h
    cases h1 : R.applyScope u sc with
    | error e => simp [h1] at h
    | ok u2 =>
      simp only [h1] at h
      have hesc' : ∀ sc ∈ l, ∀ a, sc.kind = .escape a →
          ¬ (sc.frameOffset.toInt ≤ o ∧ o < sc.frameOffset.toInt + sc.size) :=
        fun sc' hs => hesc sc' (List.mem_cons_of_mem _ hs)
      have hq' : u.st.frame o = .uninit ∨ (sc.kind = .end ∧ sc.frameOffset.toInt ≤ o ∧
          o < sc.frameOffset.toInt + sc.size) ∨ ∃ sc' ∈ l, sc'.kind = .end ∧
          sc'.frameOffset.toInt ≤ o ∧ o < sc'.frameOffset.toInt + sc'.size := by
        rcases hq with hq | ⟨sc', hs', hk⟩
        · exact .inl hq
        · rcases List.mem_cons.1 hs' with rfl | hs'
          · exact .inr (.inl hk)
          · exact .inr (.inr ⟨sc', hs', hk⟩)
      have key : u2.st.escapedAt o = none ∧ (u2.st.frame o = .uninit ∨ ∃ sc' ∈ l,
          sc'.kind = .end ∧ sc'.frameOffset.toInt ≤ o ∧ o < sc'.frameOffset.toInt + sc'.size) := by
        unfold R.applyScope at h1
        split at h1
        · rename_i a hk
          obtain ⟨hn2, hf2⟩ := escape_private h1 hn (hesc sc (List.mem_cons_self ..) a hk)
          refine ⟨hn2, ?_⟩
          rcases hq' with hq' | ⟨hk', -⟩ | hq'
          · exact .inl (hf2.trans hq')
          · rw [hk] at hk'; cases hk'
          · exact .inr hq'
        · rename_i hk
          obtain ⟨hn2, hin2, hout2⟩ := storageEnd_private h1 hn
          refine ⟨hn2, ?_⟩
          by_cases hin : sc.frameOffset.toInt ≤ o ∧ o < sc.frameOffset.toInt + sc.size
          · exact .inl (hin2 hin)
          · rcases hq' with hq' | ⟨-, hk'⟩ | hq'
            · exact .inl ((hout2 hin).trans hq')
            · exact (hin hk').elim
            · exact .inr hq'
        · rename_i hk
          cases h1
          refine ⟨hn, ?_⟩
          rcases hq' with hq' | ⟨hk', -⟩ | hq'
          · exact .inl hq'
          · rw [hk] at hk'; cases hk'
          · exact .inr hq'
      exact private_fold l h key.1 hesc' key.2

/-- `clearHome` on two states related by `FrameRel` gives related states. -/
theorem clearHome_rel {pe : Bool} {n : Nat} {off : Int} {f1 f2 : Int → AbstractByte}
    {a b a' : OpSem.State} (hr : OpSem.FrameRel f1 f2 a b)
    (h : R.clearHome pe n off a = .ok a') :
    ∃ b', R.clearHome pe n off b = .ok b' ∧ OpSem.FrameRel f1 f2 a' b' := by
  rcases Ryo.Proofs.Shapes.clearHome_cases h with ⟨hpe, hw⟩ | ⟨hpe, rfl⟩
  · subst hpe
    have hrr := OpSem.writeFrame_rel (off := off)
      (bs := List.replicate (R.handlerHome true n) .uninit) hr
    rw [hw] at hrr
    cases hb : b.writeFrame off (List.replicate (R.handlerHome true n) .uninit) with
    | error e => rw [hb] at hrr; simp only [OpSem.ResultRel] at hrr
    | ok b' =>
      rw [hb] at hrr
      refine ⟨b', ?_, hrr⟩
      unfold R.clearHome
      rw [if_pos rfl]
      exact hb
  · subst hpe
    exact ⟨b, rfl, hr⟩

/-! ### Handlers: shapes, successors and landing pads (T3a) -/

/-- What `R.view`'s `ok` check gives of a handler instruction's control flow. -/
def HCompat (h : Full.Opcode) (t : R.Then Nat) : Prop :=
  (t = .next → h.info.shape = .op ∨ h.info.shape = .lpad) ∧
    (∀ neg x, t = .branch neg x → h.info.shape = .br)

theorem view_handler_compat {mode : Ryo.Obj.Mode} {ρ : R.Addrs} {h : Full.Opcode}
    {args : List R.Arg} {t : R.Then Nat} {v : R.View}
    (hv : R.view mode ρ (.handler h args t) = some v) : HCompat h t := by
  refine ⟨fun ht => ?_, fun neg x ht => ?_⟩
  · subst ht
    cases hsh : h.info.shape <;>
      first
      | exact Or.inl rfl
      | exact Or.inr rfl
      | (exfalso
         simp only [R.view, hsh, Option.bind_eq_bind] at hv
         split at hv <;> (try cases hv) <;>
           (cases hu : R.unpack ρ h mode args <;> simp [hu] at hv))
  · subst ht
    cases hsh : h.info.shape <;>
      first
      | rfl
      | (exfalso
         simp only [R.view, hsh, Option.bind_eq_bind] at hv
         split at hv <;> (try cases hv) <;>
           (cases hu : R.unpack ρ h mode args <;> simp [hu] at hv))

/-- A handler instruction's successor by `Then.succ`, in range, is a `flow` successor. -/
theorem flow_succ_handler {d : Decoded} {k : Nat} {h : Full.Opcode} {args : List R.Arg}
    {t : R.Then Nat} (hi : d.insns[k]? = some (.handler h args t)) (hc : HCompat h t)
    {ctl : OpSem.Control} {y : Nat} (hs : t.succ k ctl = some y) (hy : y < d.insns.size) :
    y ∈ (Frame.flow d).1[k]! := by
  have hk : k < d.insns.size := by
    rcases Nat.lt_or_ge k d.insns.size with h | h
    · exact h
    · rw [Array.getElem?_eq_none h] at hi; cases hi
  unfold Frame.flow
  simp only [Id.run_bind, Id.run_pure, Std.Legacy.Range.forIn'_eq_forIn'_range',
    Std.Legacy.Range.size]
  refine forIn'_push_mem (R := fun a x => ∀ h args t, d.insns[a]? = some (.handler h args t) →
    HCompat h t → ∀ ctl y, t.succ a ctl = some y → y < d.insns.size → y ∈ x) _ ?_
    (by simpa using hk) (fun x hR => hR h args t hi hc ctl y hs hy)
  intro a hm b
  refine ⟨_, rfl, ?_⟩
  intro h' args' t' hop hc' ctl' y' hs' hy'
  have hd : ∀ hh : a < d.insns.size, d.insns[a]'hh = .handler h' args' t' := fun hh => by
    rw [Array.getElem?_eq_getElem hh] at hop
    exact Option.some.inj hop
  simp only [hd]
  cases t' <;> cases ctl' <;> simp only [R.Then.succ, reduceCtorEq] at hs'
  · -- next
    simp only [Option.some.injEq] at hs'
    subst hs'
    rcases hc'.1 rfl with hsh | hsh <;> simp [hsh, hy']
  · -- branch
    rename_i neg x b
    simp only [Option.some.injEq] at hs'
    subst hs'
    have hsh := hc'.2 neg x rfl
    by_cases hb : (b != neg) = true
    · simp only [hb, ↓reduceIte] at hy' ⊢
      exact List.mem_filter.2 ⟨List.mem_append_right _ (List.mem_singleton_self _),
        by simpa using hy'⟩
    · simp only [hb, Bool.false_eq_true, ↓reduceIte] at hy' ⊢
      simp [hsh, hy']
  · -- table
    exact List.mem_filter.2 ⟨List.mem_append_right _ (List.mem_iff_getElem?.2 ⟨_, hs'⟩),
      by simpa using hy'⟩

theorem flowOf_pad {d : Decoded} {mode : Ryo.Obj.Mode} {facts : Frame.Facts} {fl : Frame.Flow}
    (h : Frame.Flow.of d mode facts = .ok fl) : fl.pad = (Frame.flow d).2 := by
  unfold Frame.Flow.of at h
  simp only [bind, Except.bind] at h
  split at h
  · cases h
  · simp only [pure, Except.pure, Except.ok.injEq] at h
    subst h
    rfl

theorem forIn_pad_aux {n : Nat}
    (f : (Nat × Option Nat × Bool) → Array (List Nat) → Id (ForInStep (Array (List Nat))))
    (hf : ∀ (x : Nat × Option Nat × Bool) (b : Array (List Nat)), b.size = n →
      ∃ b' : Array (List Nat), f x b = pure (ForInStep.yield b') ∧ b'.size = n ∧
      (∀ (k y : Nat), y ∈ b[k]! → y ∈ b'[k]!) ∧
      (∀ p : Nat, x.2.1 = some p → x.1 < n → p < n → p ∈ b'[x.1]!)) :
    ∀ (l : List (Nat × Option Nat × Bool)) (A : Array (List Nat)), A.size = n →
      (∀ (k y : Nat), y ∈ A[k]! → y ∈ (forIn l A f).run[k]!) ∧
      ∀ x ∈ l, ∀ p : Nat, x.2.1 = some p → x.1 < n → p < n → p ∈ (forIn l A f).run[x.1]!
  | [], A, _ => ⟨fun k y h => h, fun x hx => by cases hx⟩
  | a :: l, A, hA => by
    obtain ⟨b', hb', hsz, hmono, hnew⟩ := hf a A hA
    have hrun : (forIn (a :: l) A f).run = (forIn l b' f).run := by
      rw [List.forIn_cons, hb', pure_bind]
      all_goals rfl
    obtain ⟨ih1, ih2⟩ := forIn_pad_aux f hf l b' hsz
    refine ⟨fun k y h => ?_, fun x hx p hp hk hpn => ?_⟩
    · rw [hrun]; exact ih1 k y (hmono k y h)
    · rw [hrun]
      rcases List.mem_cons.1 hx with rfl | hx
      · exact ih1 _ _ (hnew p hp hk hpn)
      · exact ih2 x hx p hp hk hpn

/-- A landing pad of instruction `k` (its cleanup entry), in range, is one of `flow`'s pads. -/
theorem flow_pad_mem {d : Decoded} {k p : Nat} {b : Bool}
    (hc : (d.cleanup.find? (·.1 == k)).map (·.2) = some (some p, b)) (hk : k < d.insns.size)
    (hp : p < d.insns.size) : p ∈ (Frame.flow d).2[k]! := by
  obtain ⟨e, he, hem⟩ : ∃ e, d.cleanup.find? (·.1 == k) = some e ∧ e.2 = (some p, b) := by
    cases hf : d.cleanup.find? (·.1 == k) with
    | none => rw [hf] at hc; cases hc
    | some e => rw [hf] at hc; exact ⟨e, rfl, Option.some.inj hc⟩
  have hek : e.1 = k := by simpa using Array.find?_some he
  have hmem : e ∈ d.cleanup.toList.reverse :=
    List.mem_reverse.2 (Array.mem_toList_iff.2 (Array.mem_of_find?_eq_some he))
  unfold Frame.flow
  simp only [Id.run_bind, Id.run_pure, Std.Legacy.Range.forIn'_eq_forIn'_range',
    Std.Legacy.Range.size]
  rw [← hek]
  refine (forIn_pad_aux (n := d.insns.size) _ ?_ _ _ (by simp)).2 e hmem p (by rw [hem])
    (by rw [hek]; exact hk) hp
  · intro x bb hbb
    obtain ⟨c, q, z⟩ := x
    cases q with
    | none => exact ⟨bb, rfl, hbb, fun k y h => h, fun p hp => by cases hp⟩
    | some q =>
      by_cases hcq : c < d.insns.size ∧ q < d.insns.size
      · refine ⟨bb.modify c (q :: ·), by simp [hcq.1, hcq.2], by simp [hbb],
          fun k y h => ?_, fun p' hp' _ _ => ?_⟩
        · simp only [Array.getElem!_eq_getD, Array.getD_eq_getD_getElem?,
            Array.getElem?_modify] at h ⊢
          split
          · cases hk' : bb[k]? with
            | none => simp_all
            | some l => simp_all
          · exact h
        · simp only [Option.some.injEq] at hp'
          subst hp'
          show q ∈ (bb.modify c (q :: ·))[c]!
          simp only [Array.getElem!_eq_getD, Array.getD_eq_getD_getElem?, Array.getElem?_modify,
            if_pos rfl]
          rw [Array.getElem?_eq_getElem (by omega : c < bb.size)]
          simp
      · refine ⟨bb, ?_, hbb, fun k y h => h, fun p' hp' hc' hp'n => ?_⟩
        · have : ¬ (c < d.insns.size ∧ q < d.insns.size) := hcq
          simp only [Bool.and_eq_true, decide_eq_true_eq] at this ⊢
          simp [this]
        · simp only [Option.some.injEq] at hp'
          subst hp'
          exact absurd ⟨hc', hp'n⟩ hcq

/-! ### Handlers: the assembly (T3a) -/

theorem view_handler_unpack {mode : Ryo.Obj.Mode} {ρ : R.Addrs} {h : Full.Opcode}
    {args : List R.Arg} {t : R.Then Nat} {v : R.View}
    (hv : R.view mode ρ (.handler h args t) = some v) : R.unpack ρ h mode args = some v.ops := by
  simp only [R.view, Option.bind_eq_bind] at hv
  split at hv
  · cases hv
  cases hu : R.unpack ρ h mode args with
  | none => simp [hu] at hv
  | some vals =>
    simp only [hu, Option.bind_some] at hv
    split at hv <;> simp_all <;>
      first
      | (subst hv; rfl)
      | (obtain ⟨-, rfl⟩ := hv; rfl)

/-- A bit of ranges all among `k`'s operand reads is in `gen k`. -/
theorem gen_of_operand_mem {fl : Frame.Flow} {k : Nat} {L : Frame.Ranges}
    (hsub : ∀ r ∈ L, r ∈ fl.operand[k]!) {i : Nat} (hb : (Frame.Ranges.bits L).testBit i = true) :
    (fl.gen k).testBit i = true := by
  rw [testBit_rangesBits] at hb
  obtain ⟨r, hr, hri⟩ := List.any_eq_true.1 hb
  unfold Frame.Flow.gen Frame.Flow.direct
  rw [Nat.testBit_or, testBit_rangesBits, List.any_append]
  simp only [Bool.or_eq_true]
  exact .inl (.inl (List.any_eq_true.2 ⟨r, hsub r hr, hri⟩))

/-- A frame byte in `ends[k]` is in an `End` scope before `k`. -/
theorem end_scope_of_bit {k : Nat} {o : Int} (hif : InFrame S o)
    (hb : (Frame.Ranges.bits ((Frame.scopesAt S.c.d)[k]!.filterMap fun (_, sc) =>
      if sc.kind == .end then some (Frame.range S.c.d.frameSize sc.frameOffset sc.size)
      else none)).testBit (bit S o) = true) :
    ∃ sc ∈ S.c.scopesAt k, sc.kind = .end ∧ sc.frameOffset.toInt ≤ o ∧
      o < sc.frameOffset.toInt + sc.size := by
  rw [testBit_rangesBits] at hb
  obtain ⟨rg, hr, hri⟩ := List.any_eq_true.1 hb
  obtain ⟨⟨j, sc⟩, hjm, hjr⟩ := List.mem_filterMap.1 hr
  by_cases hk : sc.kind = .end
  · simp [hk] at hjr
    subst hjr
    have hsc' := mem_scopesAt_of_frame hjm S.c rfl
    simp only [Bool.and_eq_true, decide_eq_true_eq] at hri
    obtain ⟨hr1, hr2⟩ := hri
    obtain ⟨hf1, hf2⟩ := hif
    simp only [Frame.range, bit] at hr1 hr2
    exact ⟨sc, hsc', hk, by omega, by omega⟩
  · simp [hk] at hjr

theorem clearHome_frame {pe : Bool} {n : Nat} {off : Int} {a a' : OpSem.State}
    (h : R.clearHome pe n off a = .ok a') :
    a'.escaped = a.escaped ∧ ∀ o, a'.frame o =
      if pe = true ∧ a.privateIn off (R.handlerHome pe n) o = true then .uninit else a.frame o := by
  rcases Ryo.Proofs.Shapes.clearHome_cases h with ⟨hpe, hw⟩ | ⟨hpe, rfl⟩
  · obtain ⟨_, -, -, hesc, hfrm⟩ := writeFrame_parts hw
    refine ⟨hesc, fun o => ?_⟩
    rw [hfrm o]
    subst hpe
    by_cases hq : a.privateIn off (R.handlerHome true n) o = true
    · simp only [List.length_replicate, hq, and_self, ↓reduceIte]
      exact getD_replicate_uninit _ _
    · simp only [List.length_replicate, hq, and_false, ↓reduceIte, Bool.false_eq_true]
  · subst hpe
    exact ⟨rfl, fun o => by simp⟩

theorem privateIn_congr {a b : OpSem.State} (he : a.escaped = b.escaped) (off : Int) (n : Nat)
    (o : Int) : a.privateIn off n o = b.privateIn off n o := by
  unfold OpSem.State.privateIn OpSem.State.escapedAt
  rw [he]

/-- T3a: a handler instruction (not `resume` or `unreachable`) whose successors are in range
(`hrange`, as `jmp`'s target). -/
theorem rnext_erase_handler_op (C : Cert S) {s t' : R.RState} {P : Int → Prop}
    (h : StepPre S C s P) {hh : Full.Opcode} {args : List R.Arg} {t : R.Then Nat}
    (hi : S.c.d.insns[s.pc]? = some (.handler hh args t)) (hres : hh ≠ .resume)
    (hun : hh ≠ .unreachable)
    (hrange : ∀ ctl y, t.succ s.pc ctl = some y → y ≤ S.c.d.insns.size)
    (hn : RNext S.c (erase s P) t') : StepOut S C s P t' := by
  have hi' : S.c.d.insns[(erase s P).pc]? = some (.handler hh args t) := hi
  have hst : ∃ ch, R.step S.c (erase s P) ch = .ok (.step t') := by
    cases hn with
    | step hstep => exact ⟨_, hstep⟩
    | answer hstep _ =>
      obtain ⟨_, _, _, _, _, _, _, _, _, _, _, _, hc⟩ := step_handler_ok hi' hres hun hstep
      cases hc
  obtain ⟨ch, hstep⟩ := hst
  obtain ⟨t1, v, ctl, st, st2, pc', hsc, hview, hop, ho, hch, hp, hc⟩ :=
    step_handler_ok hi' hres hun hstep
  cases hc
  obtain ⟨s1, hs1, rfl⟩ := scopes_erase_eq C h hsc
  subst hop
  have hpc : s1.pc = s.pc := (Ryo.Proofs.Scope.scopes_keeps _ hs1).pc
  have hlt := h.lt
  have hp' : t.succ s.pc ctl = some pc' := by rw [← hpc]; exact hp
  have hpcn : pc' ≤ S.c.d.insns.size := hrange ctl pc' hp'
  -- the footprint and the row
  obtain ⟨fp, hfp⟩ := opSem_fp ho
  have hu := view_handler_unpack hview
  obtain ⟨e, eb, he, hkill, hun0, hsub, hends⟩ := flowOf_handler_row C.hfl hi
  obtain ⟨hR, hW, -⟩ := handlerVals_agree S.c.d.frameSize eb hu he
  have hsucc : C.fl.succ = (Frame.flow S.c.d).1 := flowOf_succ C.hfl
  have hssz : C.fl.succ.size = S.c.d.insns.size := by rw [hsucc, flow_succ_size]
  have hpsz : C.fl.pad.size = C.fl.succ.size := (postFix_spec C.hlive).2.1
  have hkk : s.pc < C.fl.succ.size := by rw [hssz]; exact hlt
  have htin : pc' < S.c.d.insns.size → pc' ∈ C.fl.succ[s.pc]! := fun hyl => by
    rw [hsucc]; exact flow_succ_handler hi (view_handler_compat hview) hp' hyl
  -- every byte of `P` the footprint reads is `Uninit` in `s1`
  have hrd : ∀ o, (∃ rg ∈ fp.readRanges (OpSem.opndVal v.op.info v.ops),
      OpSem.inRange o rg = true) → P o → s1.st.frame o = .uninit := by
    intro o hread hpo
    obtain ⟨hif, -, hpriv, -⟩ := h.patch o hpo
    have hg := gen_of_operand_mem hsub (hR fp hfp o hif.1 hif.2 hread)
    by_cases hd : Dead S C s.pc o
    · have hend : C.fl.ends[s.pc]!.bits.testBit (bit S o) = true := by
        cases he' : C.fl.ends[s.pc]!.bits.testBit (bit S o)
        · have := live_gen C.hlive hkk hg (.inl he')
          have h2 := hd.2
          unfold bit at h2
          rw [h2] at this
          cases this
        · rfl
      rw [hends] at hend
      obtain ⟨sc, hsc', hk, h1, h2⟩ := end_scope_of_bit hif hend
      exact private_fold _ hs1 hpriv
        (fun sc hsc a hka hcov => not_dead_of_escape C hlt hsc hka hcov.1 hcov.2 hd)
        (.inr ⟨sc, hsc', hk, h1, h2⟩)
    · exact frame_uninit_of_live C h hs1 hpo hd
  have hfeq : ∀ o, (∃ rg ∈ fp.readRanges (OpSem.opndVal v.op.info v.ops),
      OpSem.inRange o rg = true) → (eraseSt P s1.st).frame o = s1.st.frame o := by
    intro o hread
    by_cases hpo : P o
    · simp only [eraseSt, hpo, ↓reduceIte]
      exact (hrd o hread hpo).symm
    · simp only [eraseSt, hpo, ↓reduceIte]
  -- R's own `opSem`
  obtain ⟨⟨ctl2, stR⟩, ho2, hctl, hfr⟩ := opSem_erase (st := s1.st) hfp hrd ho
  simp only at hctl
  subst hctl
  have hsb : (eraseSt P s1.st).SameButFrame s1.st := ⟨rfl, rfl, rfl, rfl, rfl⟩
  have hexact : ∀ o, (∃ rg ∈ fp.writeRanges (OpSem.opndVal v.op.info v.ops),
      OpSem.inRange o rg = true) → st.frame o = stR.frame o :=
    h.fpExact v.op v.ops (eraseSt P s1.st) s1.st ch fp (ctl, st) (ctl, stR) hfp hsb hfeq ho ho2
  have hun1 : ∀ o, (∀ rg ∈ fp.writeRanges (OpSem.opndVal v.op.info v.ops),
      OpSem.inRange o rg = false) → st.frame o = (eraseSt P s1.st).frame o ∧
        stR.frame o = s1.st.frame o := fun o hno =>
    ⟨OpSem.opSem_frame_writes hfp ho o hno, OpSem.opSem_frame_writes hfp ho2 o hno⟩
  -- R's own `clearHome`
  have hescS : st.escaped = stR.escaped := hfr.1.1
  obtain ⟨stR2, hchR, hfrc⟩ := clearHome_rel hfr hch
  obtain ⟨hesc2, hfr2⟩ := clearHome_frame hch
  obtain ⟨hescR2, hfrR2⟩ := clearHome_frame hchR
  have hescR : stR.escaped = s1.st.escaped := (Ryo.Proofs.OpFacts.opSem_out ho2).2.1
  -- the successor
  let s' : R.RState := { s1 with pc := pc', st := stR2 }
  have hRstep : R.step S.c s ch = .ok (.step s') := by
    rw [Ryo.Proofs.Shapes.step_handler hi hs1]
    exact stepView_handler_of hres hun hview rfl ho2 hchR hp
  let Wr : Int → Prop := fun o => ∃ rg ∈ fp.writeRanges (OpSem.opndVal v.op.info v.ops),
    OpSem.inRange o rg = true
  let Cl : Int → Prop := fun o => S.c.mode.pe = true ∧
    stR.privateIn (-(S.c.d.frameSize : Int)) (R.handlerHome S.c.mode.pe args.length) o = true
  let P' : Int → Prop := fun o => P o ∧ ¬ Wr o ∧ ¬ Cl o ∧ s'.st.escapedAt o = none ∧
    (Dead S C s'.pc o ∨ (s'.st.byteAt o = .ok .uninit ∧ CacheCovers S s'.pc o))
  have hpriv' : ∀ o, stR.privateIn (-(S.c.d.frameSize : Int))
      (R.handlerHome S.c.mode.pe args.length) o =
      st.privateIn (-(S.c.d.frameSize : Int)) (R.handlerHome S.c.mode.pe args.length) o :=
    fun o => privateIn_congr hescS.symm _ _ o
  -- the frames of the two successors
  have hfin : ∀ o, stR2.frame o = st2.frame o ∨
      (¬ Wr o ∧ ¬ Cl o ∧ stR2.frame o = s1.st.frame o ∧
        st2.frame o = (eraseSt P s1.st).frame o) := by
    intro o
    rw [hfr2 o, hfrR2 o, ← hpriv' o]
    by_cases hcl : S.c.mode.pe = true ∧
        stR.privateIn (-(S.c.d.frameSize : Int)) (R.handlerHome S.c.mode.pe args.length) o = true
    · rw [if_pos hcl, if_pos hcl]
      exact .inl rfl
    · rw [if_neg hcl, if_neg hcl]
      by_cases hw : Wr o
      · exact .inl (hexact o hw).symm
      · have hno : ∀ rg ∈ fp.writeRanges (OpSem.opndVal v.op.info v.ops),
            OpSem.inRange o rg = false := by
          intro rg hrg
          cases hb : OpSem.inRange o rg
          · rfl
          · exact (hw ⟨rg, hrg, hb⟩).elim
        obtain ⟨h1, h2⟩ := hun1 o hno
        exact .inr ⟨hw, hcl, h2, h1⟩
  have hesc' : ∀ o, s'.st.escapedAt o = s1.st.escapedAt o := fun o => by
    show stR2.escapedAt o = _
    unfold OpSem.State.escapedAt; rw [hescR2, hescR]
  -- a byte of `P` that leaves without being written holds no ghost value
  have hleave : ∀ o, P o → ¬ Wr o → ¬ Cl o → ¬ P' o → s1.st.escapedAt o = none →
      s1.st.frame o = .uninit := by
    intro o hpo hnw hncl hno hpr
    have hpr' : s'.st.escapedAt o = none := (hesc' o).trans hpr
    obtain ⟨hif, -, hpriv, hd⟩ := h.patch o hpo
    have hnd : ¬ Dead S C pc' o := fun hd' => hno ⟨hpo, hnw, hncl, hpr', .inl hd'⟩
    rcases hd with hdead | ⟨hb, -⟩
    · have hlive : (C.fl.liveIn[pc']!).testBit (bit S o) = true := by
        cases hb : (C.fl.liveIn[pc']!).testBit (bit S o)
        · exact (hnd ⟨hif, hb⟩).elim
        · rfl
      have hyl := lt_of_live C hlive
      have hkb : C.fl.kill[s.pc]!.bits.testBit (bit S o) = false := by
        rw [hkill]
        cases hkb : (Frame.Ranges.bits
            (Frame.Flow.opndRanges S.c.d.frameSize false eb e.opnds).2).testBit (bit S o)
        · rfl
        · exact (hnw (hW fp hfp o hif.1 hif.2 hkb)).elim
      have hend : C.fl.ends[s.pc]!.bits.testBit (bit S o) = true := by
        cases he' : C.fl.ends[s.pc]!.bits.testBit (bit S o)
        · have := live_succ C.hlive hkk (htin hyl) hlive hkb
            (by rw [hun0]; simp [Frame.Ranges.bits]) he'
          rw [hdead.2] at this
          cases this
        · rfl
      rw [hends] at hend
      obtain ⟨sc, hsc', hk, h1, h2⟩ := end_scope_of_bit hif hend
      exact private_fold _ hs1 hpriv
        (fun sc hsc a hka hcov => not_dead_of_escape C hlt hsc hka hcov.1 hcov.2 hdead)
        (.inr ⟨sc, hsc', hk, h1, h2⟩)
    · refine foldlM_frame_uninit _ hs1 ?_
      simp only [OpSem.State.byteAt, hpriv] at hb
      exact Except.ok.inj hb
  have hkP : ∀ o, P' o → InFrame S o → C.fl.kill[s.pc]!.bits.testBit (bit S o) = false := by
    intro o ho hif
    rw [hkill]
    cases hkb : (Frame.Ranges.bits
        (Frame.Flow.opndRanges S.c.d.frameSize false eb e.opnds).2).testBit (bit S o)
    · rfl
    · exact (ho.2.1 (hW fp hfp o hif.1 hif.2 hkb)).elim
  have hEU : ∀ o, P' o → InFrame S o → s'.pc ∈ C.fl.succ[s.pc]! →
      C.fl.ends[s.pc]!.bits.testBit (bit S o) = true → s'.st.byteAt o = .ok .uninit := by
    intro o ho _ _ heb
    refine byteAt_of_frame ho.2.2.2.1 ?_
    show stR2.frame o = .uninit
    rw [hfrR2 o, if_neg (show ¬ (S.c.mode.pe = true ∧ stR.privateIn (-(S.c.d.frameSize : Int))
    (R.handlerHome S.c.mode.pe args.length) o = true) from ho.2.2.1)]
    have hno : ∀ rg ∈ fp.writeRanges (OpSem.opndVal v.op.info v.ops),
        OpSem.inRange o rg = false := by
      intro rg hrg
      cases hb : OpSem.inRange o rg
      · rfl
      · exact (ho.2.1 ⟨rg, hrg, hb⟩).elim
    rw [(hun1 o hno).2]
    exact (ends_noGhost C h hs1 hends ho.1 heb).resolve_left
      (fun hne => hne ((hesc' o).symm.trans ho.2.2.2.1))
  refine ⟨s', P', fun o ho => ho.1, .inr hkP, hEU, RNext.step (ch := ch) hRstep, ⟨rfl, rfl, rfl, ?_⟩,
    fun o ho => ?_, fun o ho => ?_, ?_⟩
  · -- `StEq`
    refine ⟨hfrc.1.1.symm, hfrc.1.2.2.2.2.symm, hfrc.1.2.1.symm, hfrc.1.2.2.1.symm,
      hfrc.1.2.2.2.1.symm, fun o ho => ?_⟩
    · have hpr : s1.st.escapedAt o = none := (hesc' o).symm.trans ho
      simp only [eraseSt]
      by_cases hp'o : P' o
      · simp only [hp'o, ↓reduceIte]
      · simp only [hp'o, ↓reduceIte]
        rcases hfin o with hq | ⟨hnw, hncl, h1, h2⟩
        · exact hq
        · rw [h1, h2]
          simp only [eraseSt]
          by_cases hpo : P o
          · simp only [hpo, ↓reduceIte]
            exact hleave o hpo hnw hncl hp'o hpr
          · simp only [hpo, ↓reduceIte]
  · -- the shadow's bytes at `P'` are `Uninit`
    obtain ⟨hpo, hnw, hncl, hpr, -⟩ := ho
    have hpr1 : s1.st.escapedAt o = none := (hesc' o).symm.trans hpr
    have hn' : st2.escapedAt o = none := by
      unfold OpSem.State.escapedAt; rw [hesc2, hescS, hescR]; exact hpr1
    show st2.byteAt o = .ok .uninit
    simp only [OpSem.State.byteAt, hn']
    rcases hfin o with hq | ⟨-, -, -, h2⟩
    · -- not cleared and not written: `hfin`'s second case is the only one possible
      have hno : ∀ rg ∈ fp.writeRanges (OpSem.opndVal v.op.info v.ops),
          OpSem.inRange o rg = false := by
        intro rg hrg
        cases hb : OpSem.inRange o rg
        · rfl
        · exact (hnw ⟨rg, hrg, hb⟩).elim
      have hncl' : ¬ (S.c.mode.pe = true ∧ stR.privateIn (-(S.c.d.frameSize : Int))
          (R.handlerHome S.c.mode.pe args.length) o = true) := hncl
      rw [hfr2 o, ← hpriv' o, if_neg hncl']
      rw [(hun1 o hno).1]
      simp only [eraseSt, hpo, ↓reduceIte]
      all_goals rfl
    · rw [h2]
      simp only [eraseSt, hpo, ↓reduceIte]
      all_goals rfl
  · obtain ⟨hpo, -, -, hpr, hd⟩ := ho
    obtain ⟨hif, hdr, -, -⟩ := h.patch o hpo
    exact ⟨hif, hdr, hpr, hd⟩
  · intro hyl
    have hedge : pc' ∈ C.fl.edges[s.pc]! := by
      rw [flow_edges_get hkk (by rw [hpsz]; exact hkk)]
      exact List.mem_append_left _ (htin hyl)
    exact escPre_next C.hesc hlt h.esc hs1 (show stR2.escaped = s1.st.escaped by
      rw [hescR2, hescR]) hedge

/-! ### Handlers: `resume` (T3a) -/

theorem view_handler_has {mode : Ryo.Obj.Mode} {ρ : R.Addrs} {h : Full.Opcode}
    {args : List R.Arg} {t : R.Then Nat} {v : R.View}
    (hv : R.view mode ρ (.handler h args t) = some v) : h.hasHandler = true := by
  simp only [R.view, Option.bind_eq_bind] at hv
  split at hv
  · cases hv
  · rename_i hc
    simpa using hc

/-- `stepView` of `resume`: its slot's pointer, then unwinding. -/
theorem stepView_resume_ok {c : R.Code} {s : R.RState} {ch : OpSem.Choice}
    {args : List R.Arg} {t : R.Then Nat} {o : R.Out}
    (hv : R.stepView c s (.handler .resume args t) ch = .ok o) :
    ∃ v x bs p, R.view c.mode c.ρ (.handler .resume args t) = some v ∧ v.ops = [.slot x] ∧
      s.st.readFrame x 8 = .ok bs ∧ OpSem.asPtr bs = .ok p ∧ R.unwindAt c s p = .ok o := by
  unfold R.stepView at hv
  generalize hview : R.view c.mode c.ρ (.handler .resume args t) = ov at hv
  cases ov with
  | none => simp [OpSem.illFormed, throw, throwThe, MonadExceptOf.throw] at hv
  | some v =>
    obtain ⟨hop, hctl⟩ := view_handler hview
    have h1 : (v.op == .resume) = true := by simp [hop]
    simp only [hctl, h1, ↓reduceIte, bind, Except.bind] at hv
    generalize hops : v.ops = ops at hv
    cases ops with
    | nil => simp [OpSem.illFormed, throw, throwThe, MonadExceptOf.throw] at hv
    | cons o1 rest =>
      cases rest with
      | cons _ _ => simp [OpSem.illFormed, throw, throwThe, MonadExceptOf.throw] at hv
      | nil =>
        cases o1
        case slot x =>
          dsimp only at hv
          cases hrf : s.st.readFrame x 8 with
          | error e => rw [hrf] at hv; simp at hv
          | ok bs =>
            rw [hrf] at hv
            try simp only at hv
            cases hap : OpSem.asPtr bs with
            | error e => rw [hap] at hv; simp at hv
            | ok p =>
              rw [hap] at hv
              try simp only at hv
              exact ⟨v, x, bs, p, rfl, hops, hrf, hap, hv⟩
        all_goals simp [OpSem.illFormed, throw, throwThe, MonadExceptOf.throw] at hv

/-- The bytes of `P` an instruction at `pc` reads through its row's operand reads are `Uninit`
in the frame after its scopes. -/
theorem read_uninit (C : Cert S) {s s1 : R.RState} {P : Int → Prop} (h : StepPre S C s P)
    (hs1 : (S.c.scopesAt s.pc).foldlM R.applyScope s = .ok s1)
    (hends : C.fl.ends[s.pc]! = (Frame.scopesAt S.c.d)[s.pc]!.filterMap fun (_, sc) =>
      if sc.kind == .end then some (Frame.range S.c.d.frameSize sc.frameOffset sc.size) else none)
    {o : Int} (hpo : P o) (hg : (C.fl.gen s.pc).testBit (bit S o) = true) :
    s1.st.frame o = .uninit := by
  obtain ⟨hif, -, hpriv, -⟩ := h.patch o hpo
  have hssz : C.fl.succ.size = S.c.d.insns.size := by
    rw [flowOf_succ C.hfl, flow_succ_size]
  have hkk : s.pc < C.fl.succ.size := by rw [hssz]; exact h.lt
  by_cases hd : Dead S C s.pc o
  · have hend : C.fl.ends[s.pc]!.bits.testBit (bit S o) = true := by
      cases he' : C.fl.ends[s.pc]!.bits.testBit (bit S o)
      · have := live_gen C.hlive hkk hg (.inl he')
        rw [hd.2] at this
        cases this
      · rfl
    rw [hends] at hend
    obtain ⟨sc, hsc', hk, h1, h2⟩ := end_scope_of_bit hif hend
    exact private_fold _ hs1 hpriv
      (fun sc hsc a hka hcov => not_dead_of_escape C h.lt hsc hka hcov.1 hcov.2 hd)
      (.inr ⟨sc, hsc', hk, h1, h2⟩)
  · exact frame_uninit_of_live C h hs1 hpo hd

/-- The shadow's bytes in `[off, off + n)` are the state's when each private byte of `P` there
has an `Uninit` frame field. -/
theorem readFrame_erase_of {P : Int → Prop} {st : OpSem.State} {off : Int} {n : Nat}
    (hf : ∀ o, off ≤ o → o < off + n → P o → st.escapedAt o = none → st.frame o = .uninit) :
    (eraseSt P st).readFrame off n = st.readFrame off n := by
  unfold OpSem.State.readFrame
  apply OpSem.mapM_congr
  intro i hi
  simp only [List.mem_range] at hi
  by_cases hp : P (off + i)
  · cases he : st.escapedAt (off + i) with
    | some e =>
      have he' : (eraseSt P st).escapedAt (off + i) = some e := he
      simp only [OpSem.State.byteAt, he, he']
      all_goals rfl
    | none =>
      have he' : (eraseSt P st).escapedAt (off + i) = none := he
      have hfr := hf (off + i) (by omega) (by omega) hp he
      simp only [OpSem.State.byteAt, he, he', hfr]
      simp only [eraseSt, hp, ↓reduceIte]
      all_goals rfl
  · exact Ryo.Proofs.Scope.byteAt_congr rfl (by simp [eraseSt, hp]) (fun _ _ => rfl)

/-- T3a: `resume`, its landing pad in range (`hpad`). -/
theorem rnext_erase_handler_resume (C : Cert S) {s t' : R.RState} {P : Int → Prop}
    (h : StepPre S C s P) {args : List R.Arg} {t : R.Then Nat}
    (hi : S.c.d.insns[s.pc]? = some (.handler .resume args t))
    (hpad : ∀ pad b, S.c.cleanupAt s.pc = some (some pad, b) → pad < S.c.d.insns.size)
    (hn : RNext S.c (erase s P) t') : StepOut S C s P t' := by
  have hi' : S.c.d.insns[(erase s P).pc]? = some (.handler .resume args t) := hi
  -- the shadow's step
  have key : ∀ ch o, R.step S.c (erase s P) ch = .ok o → ∃ s1 v x bs p,
      (S.c.scopesAt s.pc).foldlM R.applyScope (erase s P) = .ok s1 ∧
      R.view S.c.mode S.c.ρ (.handler .resume args t) = some v ∧ v.ops = [.slot x] ∧
      s1.st.readFrame x 8 = .ok bs ∧ OpSem.asPtr bs = .ok p ∧ R.unwindAt S.c s1 p = .ok o := by
    intro ch o hst
    obtain ⟨s1, hsc⟩ := step_scopes_ok hst
    rw [Ryo.Proofs.Shapes.step_handler hi' hsc] at hst
    obtain ⟨v, x, bs, p, hv, hx, hrf, hap, hun⟩ := stepView_resume_ok hst
    exact ⟨s1, v, x, bs, p, hsc, hv, hx, hrf, hap, hun⟩
  have hst : ∃ ch, R.step S.c (erase s P) ch = .ok (.step t') := by
    cases hn with
    | step hstep => exact ⟨_, hstep⟩
    | answer hstep _ =>
      obtain ⟨_, _, _, _, _, _, _, _, _, _, hun⟩ := key _ _ hstep
      unfold R.unwindAt at hun
      split at hun <;> simp [OpSem.ub, throw, throwThe, MonadExceptOf.throw, pure, Except.pure] at hun
  obtain ⟨ch, hstep⟩ := hst
  obtain ⟨t1, v, x, bs, p, hsc, hview, hx, hrf, hap, hunw⟩ := key _ _ hstep
  obtain ⟨s1, hs1, rfl⟩ := scopes_erase_eq C h hsc
  have hpc : s1.pc = s.pc := (Ryo.Proofs.Scope.scopes_keeps _ hs1).pc
  have hlt := h.lt
  -- the unwinding
  unfold R.unwindAt at hunw
  cases hcl : S.c.cleanupAt (erase s1 P).pc with
  | none => rw [hcl] at hunw; simp [OpSem.ub, throw, throwThe, MonadExceptOf.throw] at hunw
  | some cb =>
    obtain ⟨opad, b⟩ := cb
    cases opad with
    | none =>
      rw [hcl] at hunw
      simp only [pure, Except.pure, Except.ok.injEq] at hunw
      cases hunw
    | some pad =>
      rw [hcl] at hunw
      simp only [pure, Except.pure, Except.ok.injEq, R.Out.step.injEq] at hunw
      subst hunw
      have hcl' : S.c.cleanupAt s.pc = some (some pad, b) := by rw [← hpc]; exact hcl
      have hpadn := hpad pad b hcl'
      -- the row, and the pad edge
      obtain ⟨e, eb, he, -, hun0, hsub, hends⟩ := flowOf_handler_row C.hfl hi
      have hu := view_handler_unpack hview
      obtain ⟨-, -, hRes⟩ := handlerVals_agree S.c.d.frameSize eb hu he
      have hssz : C.fl.succ.size = S.c.d.insns.size := by
        rw [flowOf_succ C.hfl, flow_succ_size]
      have hpsz : C.fl.pad.size = C.fl.succ.size := (postFix_spec C.hlive).2.1
      have hkk : s.pc < C.fl.succ.size := by rw [hssz]; exact hlt
      have hpin : pad ∈ C.fl.pad[s.pc]! := by
        rw [flowOf_pad C.hfl]; exact flow_pad_mem hcl' hlt hpadn
      -- the bytes read agree
      have hrd : ∀ o, x ≤ o → o < x + 8 → P o → s1.st.frame o = .uninit := by
        intro o h1 h2 hpo
        obtain ⟨hif, -, -, -⟩ := h.patch o hpo
        exact read_uninit C h hs1 hends hpo
          (gen_of_operand_mem hsub (hRes rfl x hx o hif.1 hif.2 h1 h2))
      have hrf2 : s1.st.readFrame x 8 = .ok bs := by
        rw [← readFrame_erase_of (fun o h1 h2 hpo _ => hrd o h1 (by omega) hpo)]
        exact hrf
      -- R's step
      let s' : R.RState := { s1 with pc := pad, st := { s1.st with exception := p } }
      have hRstep : R.step S.c s ch = .ok (.step s') := by
        rw [Ryo.Proofs.Shapes.step_handler hi hs1]
        unfold R.stepView
        have hctl := (view_handler hview).2
        have h1 : (v.op == .resume) = true := by simp [(view_handler hview).1]
        simp only [hview, hctl, h1, ↓reduceIte, bind, Except.bind, hx, hrf2, hap]
        unfold R.unwindAt
        rw [show S.c.cleanupAt s1.pc = some (some pad, b) from hcl]
        all_goals rfl
      let P' : Int → Prop := fun o => P o ∧ s'.st.escapedAt o = none ∧
        (Dead S C s'.pc o ∨ (s'.st.byteAt o = .ok .uninit ∧ CacheCovers S s'.pc o))
      have hleave : ∀ o, P o → ¬ P' o → NoGhost s1.st o := by
        intro o hpo hno
        by_cases hesc : s1.st.escapedAt o = none
        · obtain ⟨hif, -, hpriv, hd⟩ := h.patch o hpo
          have hnd : ¬ Dead S C pad o := fun hd' => hno ⟨hpo, hesc, .inl hd'⟩
          rcases hd with hdead | ⟨hb, -⟩
          · have hlive : (C.fl.liveIn[pad]!).testBit (bit S o) = true := by
              cases hb : (C.fl.liveIn[pad]!).testBit (bit S o)
              · exact (hnd ⟨hif, hb⟩).elim
              · rfl
            have hend : C.fl.ends[s.pc]!.bits.testBit (bit S o) = true := by
              cases he' : C.fl.ends[s.pc]!.bits.testBit (bit S o)
              · have := live_pad C.hlive hkk hpin hlive
                  (by rw [hun0]; simp [Frame.Ranges.bits]) he'
                rw [hdead.2] at this
                cases this
              · rfl
            rw [hends] at hend
            obtain ⟨sc, hsc', hk, h1, h2⟩ := end_scope_of_bit hif hend
            exact noGhost_foldlM _ hs1 (.inr ⟨sc, hsc', hk, h1, h2⟩)
          · refine noGhost_foldlM _ hs1 (.inl (.inr ?_))
            simp only [OpSem.State.byteAt, hpriv] at hb
            exact Except.ok.inj hb
        · exact .inl hesc
      have hEU : ∀ o, P' o → InFrame S o → s'.pc ∈ C.fl.succ[s.pc]! →
          C.fl.ends[s.pc]!.bits.testBit (bit S o) = true → s'.st.byteAt o = .ok .uninit := by
        intro o ho _ _ heb
        exact byteAt_of_frame ho.2.1
          ((ends_noGhost C h hs1 hends ho.1 heb).resolve_left (fun hne => hne ho.2.1))
      refine ⟨s', P', fun o ho => ho.1, .inl hpin, hEU, RNext.step (ch := ch) hRstep, ⟨rfl, rfl, rfl, ?_⟩,
        fun o ho => ?_, fun o ho => ?_, ?_⟩
      · refine ⟨rfl, rfl, rfl, rfl, rfl, fun o ho => ?_⟩
        simp only [erase, eraseSt]
        by_cases hp' : P' o
        · simp only [hp', ↓reduceIte]
        · by_cases hpo : P o
          · simp only [hp', hpo, ↓reduceIte]
            rcases hleave o hpo hp' with hq | hq
            · exact (hq ho).elim
            · exact hq
          · simp only [hp', hpo, ↓reduceIte]
            all_goals rfl
      · obtain ⟨hpo, hpr, -⟩ := ho
        show (eraseSt P { s1.st with exception := p }).byteAt o = .ok .uninit
        have hn' : (eraseSt P { s1.st with exception := p }).escapedAt o = none := hpr
        simp only [OpSem.State.byteAt, hn']
        simp only [eraseSt, hpo, ↓reduceIte]
        all_goals rfl
      · obtain ⟨hpo, hpr, hd⟩ := ho
        obtain ⟨hif, hdr, -, -⟩ := h.patch o hpo
        exact ⟨hif, hdr, hpr, hd⟩
      · intro _
        have hedge : pad ∈ C.fl.edges[s.pc]! := by
          rw [flow_edges_get hkk (by rw [hpsz]; exact hkk)]
          exact List.mem_append_right _ hpin
        exact escPre_next C.hesc hlt h.esc hs1 rfl hedge

/-- T3a: a handler instruction. -/
theorem rnext_erase_handler (C : Cert S) {s t' : R.RState} {P : Int → Prop} (h : StepPre S C s P)
    (hh : ∃ f args t, S.c.d.insns[s.pc]? = some (.handler f args t))
    (hn : RNext S.c (erase s P) t') : StepOut S C s P t' := by
  obtain ⟨f, args, t, hi⟩ := hh
  by_cases hres : f = .resume
  · subst hres
    exact rnext_erase_handler_resume C h hi h.padRange hn
  by_cases hun : f = .unreachable
  · subst hun
    exfalso
    have key : ∀ ch o, R.step S.c (erase s P) ch = .ok o → False := by
      intro ch o hst
      obtain ⟨s1, hsc⟩ := step_scopes_ok hst
      have hi' : S.c.d.insns[(erase s P).pc]? = some (.handler .unreachable args t) := hi
      rw [Ryo.Proofs.Shapes.step_handler hi' hsc] at hst
      unfold R.stepView at hst
      cases hv : R.view S.c.mode S.c.ρ (.handler .unreachable args t) with
      | none =>
        rw [hv] at hst
        simp [OpSem.illFormed, throw, throwThe, MonadExceptOf.throw] at hst
      | some v =>
        have := view_handler_has hv
        rw [Ryo.Proofs.DecodeLink.noHandler.2.2.1] at this
        cases this
    cases hn with
    | step hs => exact key _ _ hs
    | answer hs _ => exact key _ _ hs
  · exact rnext_erase_handler_op C h hi hres hun (h.succRange _ _ _ hi) hn

/-! ### The other natives: shapes, `opSem` natives and islands (T3c) -/

/-- A successful step of a `jmp`, `arg` or `island` native has that shape's operands. -/
theorem step_native_shape {c : R.Code} {s : R.RState} {ch : OpSem.Choice} {o : R.Out}
    {op : Reduced.Opcode} {ops : List (Opnd Nat)} {f : Full.Opcode}
    (hi : c.d.insns[s.pc]? = some (.native op ops)) (hf : op.full = some f)
    (h : R.step c s ch = .ok o) :
    (f.info.shape = .jmp → ∃ t, ops = [.target t]) ∧
    (f.info.shape = .arg → ∃ d r, ops = [.slot d, .imm r]) ∧
    (f.info.shape = .island → ∃ isl ws, ops = [.sym isl, .words ws]) := by
  unfold R.step at h
  simp only [hi, bind, Except.bind] at h
  cases hsc : (c.scopesAt s.pc).foldlM R.applyScope s with
  | error e => simp [hsc] at h
  | ok s1 =>
    simp only [hsc, hf] at h
    refine ⟨fun hs => ?_, fun hs => ?_, fun hs => ?_⟩ <;> rw [hs] at h <;> (try dsimp only at h) <;>
      split at h <;>
      first
      | exact ⟨_, rfl⟩
      | exact ⟨_, _, rfl⟩
      | (exfalso; simp_all only [reduceCtorEq]; done)
      | (simp [OpSem.illFormed, throw, throwThe, MonadExceptOf.throw] at h; done)

/-! ### Native `opSem` instructions (T3c) -/

theorem opShape_of_ne {f : Full.Opcode} (hsj : f.info.shape ≠ .jmp) (hsa : f.info.shape ≠ .arg)
    (hsi : f.info.shape ≠ .island)
    (hcall : f.info.shape ≠ .call ∧ f.info.shape ≠ .tailCall ∧ f.info.shape ≠ .ret) :
    R.opShape f = true := by
  unfold R.opShape
  obtain ⟨h1, h2, h3⟩ := hcall
  cases hsh : f.info.shape <;>
    simp only [hsh, ne_eq, not_true_eq_false] at hsj hsa hsi h1 h2 h3 <;> rfl

set_option maxRecDepth 100000 in
theorem reduced_noResumeTable : (List.range Reduced.toFullTable.size).all (fun i =>
    match Reduced.toFullTable[i]! with
    | some f => decide (f ≠ Full.Opcode.resume)
    | none => true) = true := by
  decide +kernel

/-- No reduced (native) opcode is `resume` (its handler is assembly). -/
theorem reduced_ne_resume {op : Reduced.Opcode} {f : Full.Opcode} (h : op.full = some f) :
    f ≠ .resume := by
  rintro rfl
  unfold Reduced.Opcode.full at h
  have hlt : op.val.toNat < Reduced.toFullTable.size := Classical.byContradiction fun hn => by
    rw [getElem!_neg Reduced.toFullTable op.val.toNat hn] at h
    cases h
  have := List.all_eq_true.1 reduced_noResumeTable op.val.toNat (List.mem_range.2 hlt)
  rw [h] at this
  simp at this

/-! ### Non-inline natives have no footprint (DS-T8, piece 4c)

The reduced (native) opcodes are the inline full opcodes and those without a handler
(`Reduced.lean`): a reduced opcode with a handler is `hasInline` (a kernel table, no Strings).
With `classOf` agreeing with `hasInline`, a non-inline native has no handler, so no footprint,
and `nativeVals_agree` holds vacuously. -/

set_option maxRecDepth 100000 in
theorem reducedHandlerTable : (List.range Reduced.toFullTable.size).all (fun i =>
    match Reduced.toFullTable[i]! with
    | some f => !f.handler?.isSome || f.hasInline
    | none => true) = true := by
  decide +kernel

/-- A reduced opcode whose full opcode has a handler has an inline form. -/
theorem reduced_handler_inline {op : Reduced.Opcode} {f : Full.Opcode} (h : op.full = some f)
    (hh : f.handler?.isSome = true) : f.hasInline = true := by
  unfold Reduced.Opcode.full at h
  have hlt : op.val.toNat < Reduced.toFullTable.size := Classical.byContradiction fun hn => by
    rw [getElem!_neg Reduced.toFullTable op.val.toNat hn] at h
    cases h
  have := List.all_eq_true.1 reducedHandlerTable op.val.toNat (List.mem_range.2 hlt)
  rw [h] at this
  simpa [hh] using this

/-- `op` has no inline form, or `dsClassOfL` (`classOf` on characters) recognises its mnemonic
characters. -/
def inlineClassOk (op : Full.Opcode) : Bool :=
  !op.hasInline || match Full.mnemonicChars[op.val.toNat]? with
    | some cs => (dsClassOfL cs).isSome
    | none => false

set_option maxRecDepth 100000 in
set_option maxHeartbeats 0 in
theorem inlineClassTable_0 : (opsIn 0 100).all inlineClassOk = true := by
  decide +kernel
set_option maxRecDepth 100000 in
set_option maxHeartbeats 0 in
theorem inlineClassTable_100 : (opsIn 100 100).all inlineClassOk = true := by
  decide +kernel
set_option maxRecDepth 100000 in
set_option maxHeartbeats 0 in
theorem inlineClassTable_200 : (opsIn 200 100).all inlineClassOk = true := by
  decide +kernel
set_option maxRecDepth 100000 in
set_option maxHeartbeats 0 in
theorem inlineClassTable_300 : (opsIn 300 100).all inlineClassOk = true := by
  decide +kernel
set_option maxRecDepth 100000 in
set_option maxHeartbeats 0 in
theorem inlineClassTable_400 : (opsIn 400 100).all inlineClassOk = true := by
  decide +kernel
set_option maxRecDepth 100000 in
set_option maxHeartbeats 0 in
theorem inlineClassTable_500 : (opsIn 500 100).all inlineClassOk = true := by
  decide +kernel
set_option maxRecDepth 100000 in
set_option maxHeartbeats 0 in
theorem inlineClassTable_600 : (opsIn 600 100).all inlineClassOk = true := by
  decide +kernel
set_option maxRecDepth 100000 in
set_option maxHeartbeats 0 in
theorem inlineClassTable_700 : (opsIn 700 100).all inlineClassOk = true := by
  decide +kernel
set_option maxRecDepth 100000 in
set_option maxHeartbeats 0 in
theorem inlineClassTable_800 : (opsIn 800 100).all inlineClassOk = true := by
  decide +kernel
set_option maxRecDepth 100000 in
set_option maxHeartbeats 0 in
theorem inlineClassTable_900 : (opsIn 900 5).all inlineClassOk = true := by
  decide +kernel
theorem inlineClassTable : Full.all.all inlineClassOk = true := by
  rw [all_eq_opsIn]
  have h1 : (opsIn 0 200).all inlineClassOk = true :=
    all_opsIn_append (m := 100) (n := 100) rfl inlineClassTable_0 inlineClassTable_100
  have h2 : (opsIn 0 300).all inlineClassOk = true :=
    all_opsIn_append (m := 200) (n := 100) rfl h1 inlineClassTable_200
  have h3 : (opsIn 0 400).all inlineClassOk = true :=
    all_opsIn_append (m := 300) (n := 100) rfl h2 inlineClassTable_300
  have h4 : (opsIn 0 500).all inlineClassOk = true :=
    all_opsIn_append (m := 400) (n := 100) rfl h3 inlineClassTable_400
  have h5 : (opsIn 0 600).all inlineClassOk = true :=
    all_opsIn_append (m := 500) (n := 100) rfl h4 inlineClassTable_500
  have h6 : (opsIn 0 700).all inlineClassOk = true :=
    all_opsIn_append (m := 600) (n := 100) rfl h5 inlineClassTable_600
  have h7 : (opsIn 0 800).all inlineClassOk = true :=
    all_opsIn_append (m := 700) (n := 100) rfl h6 inlineClassTable_700
  have h8 : (opsIn 0 900).all inlineClassOk = true :=
    all_opsIn_append (m := 800) (n := 100) rfl h7 inlineClassTable_800
  have h9 : (opsIn 0 905).all inlineClassOk = true :=
    all_opsIn_append (m := 900) (n := 5) rfl h8 inlineClassTable_900
  exact h9

/-- Lean's `classOf` (by mnemonic) recognises every opcode Rust's `has_inline` marks: by
`inlineClassTable` on the mnemonic characters (`mnemonic_chars`, `dsClassOfL_eq`). -/
theorem hasInline_classOf {f : Full.Opcode} (h : f.hasInline = true) :
    (Asm.classOf f).isSome = true := by
  have hlt : f.val.toNat < Full.count := by
    refine Classical.byContradiction fun hn => ?_
    have hsz : Asm.asmInfos.size = Full.count := by decide +kernel
    unfold Full.Opcode.hasInline Full.Opcode.asm at h
    rw [getElem!_neg Asm.asmInfos f.val.toNat (by omega)] at h
    exact absurd h (by decide)
  have hmem : f ∈ Full.all := by
    unfold Full.all
    refine List.mem_map.2 ⟨f.val.toNat, List.mem_range.2 hlt, ?_⟩
    cases f; simp
  have ht := List.all_eq_true.1 inlineClassTable f hmem
  unfold inlineClassOk at ht
  have ha : Full.all[f.val.toNat]? = some f := by
    unfold Full.all
    rw [List.getElem?_map, List.getElem?_range hlt]
    cases f; simp
  have e := congrArg (fun l => l[f.val.toNat]?) Ryo.Proofs.Inline.mnemonic_chars
  cases hc : Full.mnemonicChars[f.val.toNat]? with
  | none => simp [h, hc] at ht
  | some cs =>
    simp [List.getElem?_map, ha, hc] at e
    unfold Asm.classOf
    rw [e, ← dsClassOfL_eq]
    simpa [h, hc] using ht

/-- A non-inline native has no footprint. -/
theorem native_footprint_none {op : Reduced.Opcode} {f : Full.Opcode} (hf : op.full = some f)
    (hni : (op.full.bind Asm.classOf).isSome = false) : OpSem.footprint f = none := by
  have hni' : (Asm.classOf f).isSome = false := by rw [hf] at hni; exact hni
  cases hfp : OpSem.footprint f with
  | none => rfl
  | some fp =>
    exfalso
    have hfp' := hfp
    unfold OpSem.footprint at hfp'
    have hh : f.handler?.isSome = true := by
      cases hh : f.handler? with
      | none => rw [hh] at hfp'; cases hfp'
      | some hi => rfl
    rw [hasInline_classOf (reduced_handler_inline hf hh)] at hni'
    cases hni'

/-- `Frame.native`'s row covers what `opSem` reads by its footprint over `nativeVals`, and
kills only bytes the footprint writes: vacuously, a non-inline native having no footprint
(`native_footprint_none`). -/
theorem nativeVals_agree {ρ : R.Addrs} {op : Reduced.Opcode} {ops : List (Opnd Nat)}
    {f : Full.Opcode} {vals : OpSem.Operands} (pe : Bool) (lends : List (BitVec 32 × Nat))
    (tmpl : Option String) (F eb : Nat) (hf : op.full = some f)
    (hni : (op.full.bind Asm.classOf).isSome = false)
    (_hv : Ryo.Proofs.Inline.nativeVals ρ f ops = some vals) :
    (∀ fp, OpSem.footprint f = some fp → ∀ o : Int, -(F : Int) ≤ o → o < 0 →
      (∃ rg ∈ fp.readRanges (OpSem.opndVal f.info vals), OpSem.inRange o rg = true) →
      (Frame.Ranges.bits (Frame.Flow.opndRanges F false eb
        (Frame.native op ops pe lends tmpl).opnds).1).testBit (o + F).toNat = true) ∧
    (∀ fp, OpSem.footprint f = some fp → ∀ o : Int, -(F : Int) ≤ o → o < 0 →
      (Frame.Ranges.bits (Frame.Flow.opndRanges F false eb
        (Frame.native op ops pe lends tmpl).opnds).2).testBit (o + F).toNat = true →
      ∃ rg ∈ fp.writeRanges (OpSem.opndVal f.info vals), OpSem.inRange o rg = true) := by
  have hnone := native_footprint_none hf hni
  refine ⟨?_, ?_⟩
  · intro fp hfp; rw [hnone] at hfp; cases hfp
  · intro fp hfp; rw [hnone] at hfp; cases hfp

/-- At a non-inline native `opSem` instruction: its row from `Frame.native`. -/
theorem flowOf_native_row {d : Decoded} {mode : Ryo.Obj.Mode} {facts : Frame.Facts}
    {fl : Frame.Flow} (h : Frame.Flow.of d mode facts = .ok fl) {k : Nat} {op : Reduced.Opcode}
    {ops : List (Opnd Nat)} (hi : d.insns[k]? = some (.native op ops))
    (hni : (op.full.bind Asm.classOf).isSome = false)
    (hc1 : (op.info.shape == .call) = false) (hc2 : (op.info.shape == .tailCall) = false) :
    ∃ eb, fl.kill[k]! = (Frame.Flow.opndRanges d.frameSize false eb
        (Frame.native op ops mode.pe (Frame.Flow.lendsOf (Frame.scopesAt d) k)
          (facts.islandTemplate k)).opnds).2 ∧
      fl.uninit[k]! = [] ∧
      (∀ r ∈ (Frame.Flow.opndRanges d.frameSize false eb
        (Frame.native op ops mode.pe (Frame.Flow.lendsOf (Frame.scopesAt d) k)
          (facts.islandTemplate k)).opnds).1, r ∈ fl.operand[k]!) ∧
      fl.ends[k]! = (Frame.scopesAt d)[k]!.filterMap fun (_, sc) =>
        if sc.kind == .end then some (Frame.range d.frameSize sc.frameOffset sc.size) else none := by
  have hk : k < d.insns.size := by
    rcases Nat.lt_or_ge k d.insns.size with h | h
    · exact h
    · rw [Array.getElem?_eq_none h] at hi; cases hi
  have hik : d.insns[k]! = .native op ops := by
    rw [getElem!_pos d.insns k hk]
    rw [Array.getElem?_eq_getElem hk] at hi
    exact Option.some.inj hi
  obtain ⟨e, he, eb, hkl, hun, hen, hop⟩ := flowOf_row4 h hk
  rw [hik] at he
  simp only [Frame.effects, hni, Bool.false_eq_true, ↓reduceIte, pure, Except.pure,
    Except.ok.injEq] at he
  subst he
  refine ⟨eb, ?_, ?_, fun r hr => ?_, ?_⟩
  · rw [hkl]
    simp only [Frame.Flow.rowOf, Frame.Flow.callInfo, hik, hc1, hc2, Bool.false_or]
  · rw [hun]
    simp only [Frame.Flow.rowOf, Frame.Flow.callInfo, hik, hc1]
    all_goals rfl
  · rw [hop]
    simp only [Frame.Flow.rowOf, Frame.Flow.callInfo, hik, hc1, hc2, Bool.false_or]
    exact List.mem_append_left _ hr
  · rw [hen]
    all_goals rfl

set_option maxRecDepth 8000 in
/-- What `nativeCtl` gives: the shape, and targets among the operands. -/
theorem nativeCtl_spec {f : Full.Opcode} {ops : List (Opnd Nat)} {t : R.Then Nat}
    (hc : R.nativeCtl f ops = some t) :
    (t = .next → f.info.shape = .op ∨ f.info.shape = .lpad) ∧
    (∀ n x, t = .branch n x → f.info.shape = .br ∧ ∃ o ∈ ops, x ∈ Opnd.targetsOf o) ∧
    (∀ ts, t = .table ts → ∀ y ∈ ts, ∃ o ∈ ops, y ∈ Opnd.targetsOf o) := by
  have hnamed : ∀ (nm : String) (v : Opnd Nat),
      ((f.info.operands.zip ops).find? (·.1.name == nm)).map (·.2) = some v → v ∈ ops := by
    intro nm v hv
    cases hfd : (f.info.operands.zip ops).find? (·.1.name == nm) with
    | none => rw [hfd] at hv; cases hv
    | some pr =>
      rw [hfd] at hv
      simp only [Option.map_some, Option.some.injEq] at hv
      rw [← hv]
      exact (List.of_mem_zip (List.mem_of_find?_eq_some hfd)).2
  unfold R.nativeCtl at hc
  cases hsh : f.info.shape
  case br =>
    simp only [hsh] at hc
    split at hc
    · rename_i n x heq
      simp only [Option.pure_def, Option.some.injEq] at hc
      subst hc
      refine ⟨fun h => (by cases h), fun n' x' h => ?_, fun ts h => by cases h⟩
      cases h
      simp only [Prod.mk.injEq] at heq
      exact ⟨rfl, _, hnamed _ _ heq.2, by simp only [Opnd.targetsOf, List.mem_singleton]⟩
    · cases hc
  case switch =>
    simp only [hsh] at hc
    split at hc
    · rename_i dft heq
      simp only [Option.pure_def, Option.some.injEq] at hc
      subst hc
      refine ⟨fun h => (by cases h), fun n x h => (by cases h), fun ts h y hy => ?_⟩
      cases h
      rcases List.mem_append.1 hy with hy | hy
      · obtain ⟨o, ho, hyo⟩ := List.mem_flatMap.1 hy
        refine ⟨o, ho, ?_⟩
        cases o <;> simp only [Opnd.targetsOf] at hyo ⊢ <;>
          first | exact hyo | (simp at hyo)
      · simp only [List.mem_singleton] at hy
        subst hy
        exact ⟨_, hnamed _ _ heq, by simp only [Opnd.targetsOf, List.mem_singleton]⟩
    · cases hc
  all_goals
    simp only [hsh] at hc
    first
    | (try simp only [Option.pure_def, Option.some.injEq] at hc
       subst hc
       exact ⟨fun h => (by first | simp only [true_or, or_true] | cases h), fun n x h => (by cases h),
         fun ts h => (by cases h)⟩)
    | (simp at hc)

/-- A native instruction's successor by its `nativeCtl`, in range, is a `flow` successor. -/
theorem flow_succ_native {d : Decoded} {k : Nat} {op : Reduced.Opcode} {ops : List (Opnd Nat)}
    {f : Full.Opcode} {t : R.Then Nat} (hi : d.insns[k]? = some (.native op ops))
    (hf : op.full = some f) (hc : R.nativeCtl f ops = some t) {ctl : OpSem.Control} {y : Nat}
    (hs : t.succ k ctl = some y) (hy : y < d.insns.size) : y ∈ (Frame.flow d).1[k]! := by
  have hk : k < d.insns.size := by
    rcases Nat.lt_or_ge k d.insns.size with h | h
    · exact h
    · rw [Array.getElem?_eq_none h] at hi; cases hi
  unfold Frame.flow
  simp only [Id.run_bind, Id.run_pure, Std.Legacy.Range.forIn'_eq_forIn'_range',
    Std.Legacy.Range.size]
  refine forIn'_push_mem (R := fun a x => ∀ op ops f t, d.insns[a]? = some (.native op ops) →
    op.full = some f → R.nativeCtl f ops = some t → ∀ ctl y, t.succ a ctl = some y →
    y < d.insns.size → y ∈ x) _ ?_ (by simpa using hk)
    (fun x hR => hR op ops f t hi hf hc ctl y hs hy)
  intro a hm b
  refine ⟨_, rfl, ?_⟩
  intro op' ops' f' t' hop hf' hc' ctl' y' hs' hy'
  have hd : ∀ hh : a < d.insns.size, d.insns[a]'hh = .native op' ops' := fun hh => by
    rw [Array.getElem?_eq_getElem hh] at hop
    exact Option.some.inj hop
  have hshr := reduced_shape hf'
  obtain ⟨hnx, hbr, htb⟩ := nativeCtl_spec hc'
  simp only [hd]
  apply List.mem_filter.2
  refine ⟨?_, by simpa using hy'⟩
  cases t' <;> cases ctl' <;> simp only [R.Then.succ, reduceCtorEq] at hs'
  · simp only [Option.some.injEq] at hs'
    subst hs'
    rcases hnx rfl with hsh | hsh <;> simp [hshr, hsh, hy']
  · rename_i neg x bb
    simp only [Option.some.injEq] at hs'
    subst hs'
    obtain ⟨hsh, o, ho, hxo⟩ := hbr neg x rfl
    by_cases hb : (bb != neg) = true
    · simp only [hb, ↓reduceIte] at hy' ⊢
      exact List.mem_append_right _ (List.mem_flatMap.2 ⟨o, ho, hxo⟩)
    · simp only [hb, Bool.false_eq_true, ↓reduceIte] at hy' ⊢
      simp [hshr, hsh, hy']
  · rename_i ts i
    obtain ⟨o, ho, hyo⟩ := htb ts rfl y' (List.mem_iff_getElem?.2 ⟨i, hs'⟩)
    exact List.mem_append_right _ (List.mem_flatMap.2 ⟨o, ho, hyo⟩)

theorem step_native_of {c : R.Code} {s s1 : R.RState} {ch : OpSem.Choice} {op : Reduced.Opcode}
    {ops : List (Opnd Nat)} {f : Full.Opcode}
    (hi : c.d.insns[s.pc]? = some (.native op ops)) (hf : op.full = some f)
    (hs : R.opShape f = true) (hsc : (c.scopesAt s.pc).foldlM R.applyScope s = .ok s1) :
    R.step c s ch = R.stepView c s1 (.native op ops) ch := by
  unfold R.step
  simp only [hi, bind, Except.bind, hsc, hf]
  rcases Ryo.Proofs.Step.opShape_cases hs with hsh | hsh | hsh | hsh | hsh <;>
    (rw [hsh]; try rfl)

theorem stepView_native_of {c : R.Code} {s : R.RState} {ch : OpSem.Choice}
    {op : Reduced.Opcode} {ops : List (Opnd Nat)} {f : Full.Opcode} {vals : OpSem.Operands}
    {t : R.Then Nat} {ctl : OpSem.Control} {st' : OpSem.State} {pc' : Nat}
    (hv : R.view c.mode c.ρ (.native op ops) = some ⟨f, vals, some t⟩)
    (hres : f ≠ .resume) (hun : f ≠ .unreachable)
    (ho : OpSem.opSem f vals s.st ch = .ok (ctl, st')) (hp : t.succ s.pc ctl = some pc') :
    R.stepView c s (.native op ops) ch = .ok (.step { s with pc := pc', st := st' }) := by
  have h1 : (f == .resume) = false := by simp [hres]
  have h2 : (f == .unreachable) = false := by simp [hun]
  unfold R.stepView
  simp only [hv, h1, h2, Bool.false_eq_true, ↓reduceIte, bind, Except.bind, ho, hp]
  all_goals rfl

/-- T3c: a non-inline native `opSem` instruction (`op`, `br`, `switch`, `trap`, `lpad`
shapes), its successors in range (`hrange`). -/
theorem rnext_erase_native_op' (C : Cert S) {s t' : R.RState} {P : Int → Prop}
    (h : StepPre S C s P) {op : Reduced.Opcode} {ops : List (Opnd Nat)} {f : Full.Opcode}
    (hi : S.c.d.insns[s.pc]? = some (.native op ops)) (hf : op.full = some f)
    (hos : R.opShape f = true) (hcall : f.info.shape ≠ .call ∧ f.info.shape ≠ .tailCall)
    (hrange : ∀ t ctl y, R.nativeCtl f ops = some t → t.succ s.pc ctl = some y →
      y ≤ S.c.d.insns.size)
    (hn : RNext S.c (erase s P) t') : StepOut S C s P t' := by
  have hi' : S.c.d.insns[(erase s P).pc]? = some (.native op ops) := hi
  have hres := reduced_ne_resume hf
  -- `unreachable`: no step
  by_cases hun : f = .unreachable
  · exfalso
    have key : ∀ ch o, R.step S.c (erase s P) ch = .ok o → False := by
      intro ch o hst
      obtain ⟨s1, -, hsv⟩ := Ryo.Proofs.Step.step_native hi' hf hos hst
      unfold R.stepView at hsv
      cases hv : R.view S.c.mode S.c.ρ (.native op ops) with
      | none =>
        rw [hv] at hsv
        simp [OpSem.illFormed, throw, throwThe, MonadExceptOf.throw] at hsv
      | some v =>
        obtain ⟨vals, t, -, -, rfl⟩ := Ryo.Proofs.Step.view_native hf hos hv
        rw [hv] at hsv
        subst hun
        simp [Ryo.Proofs.Shapes.unreachable_ne_resume, OpSem.illFormed, throw, throwThe,
          MonadExceptOf.throw] at hsv
    cases hn with
    | step hs => exact key _ _ hs
    | answer hs _ => exact key _ _ hs
  have hst : ∃ ch, R.step S.c (erase s P) ch = .ok (.step t') := by
    cases hn with
    | step hstep => exact ⟨_, hstep⟩
    | answer hstep _ =>
      obtain ⟨_, -, hsv⟩ := Ryo.Proofs.Step.step_native hi' hf hos hstep
      obtain ⟨_, _, _, _, _, _, _, _, _, hc⟩ :=
        Ryo.Proofs.Step.stepView_native hf hos hres hun hsv
      cases hc
  obtain ⟨ch, hstep⟩ := hst
  obtain ⟨t1, hsc, hsv⟩ := Ryo.Proofs.Step.step_native hi' hf hos hstep
  obtain ⟨vals, t, ctl, st, pc', hnv, hnc, ho, hp, hc⟩ :=
    Ryo.Proofs.Step.stepView_native hf hos hres hun hsv
  cases hc
  obtain ⟨s1, hs1, rfl⟩ := scopes_erase_eq C h hsc
  have hpc : s1.pc = s.pc := (Ryo.Proofs.Scope.scopes_keeps _ hs1).pc
  have hlt := h.lt
  have hp' : t.succ s.pc ctl = some pc' := by rw [← hpc]; exact hp
  have hpcn : pc' ≤ S.c.d.insns.size := hrange t ctl pc' hnc hp'
  -- the view (independent of the state)
  have hview : R.view S.c.mode S.c.ρ (.native op ops) = some ⟨f, vals, some t⟩ := by
    cases hv : R.view S.c.mode S.c.ρ (.native op ops) with
    | none =>
      unfold R.stepView at hsv
      rw [hv] at hsv
      simp [OpSem.illFormed, throw, throwThe, MonadExceptOf.throw] at hsv
    | some v =>
      obtain ⟨vals', t'', hnv', hnc', rfl⟩ := Ryo.Proofs.Step.view_native hf hos hv
      rw [hnv] at hnv'
      rw [hnc] at hnc'
      cases hnv'
      cases hnc'
      rfl
  -- the footprint and the row
  obtain ⟨fp, hfp⟩ := opSem_fp ho
  have hshr := reduced_shape hf
  have hc1 : (op.info.shape == .call) = false := by rw [hshr]; exact beq_eq_false_iff_ne.2 hcall.1
  have hc2 : (op.info.shape == .tailCall) = false := by
    rw [hshr]; exact beq_eq_false_iff_ne.2 hcall.2
  have hni : (op.full.bind Asm.classOf).isSome = false := by
    cases hb : (op.full.bind Asm.classOf).isSome
    · rfl
    · exact (h.notInline ⟨op, _, hi, hb⟩).elim
  obtain ⟨eb, hkill, hun0, hsub, hends⟩ := flowOf_native_row C.hfl hi hni hc1 hc2
  obtain ⟨hR, hW⟩ := nativeVals_agree S.c.mode.pe (Frame.Flow.lendsOf (Frame.scopesAt S.c.d) s.pc)
    (C.facts.islandTemplate s.pc) S.c.d.frameSize eb hf hni hnv
  have hsucc : C.fl.succ = (Frame.flow S.c.d).1 := flowOf_succ C.hfl
  have hssz : C.fl.succ.size = S.c.d.insns.size := by rw [hsucc, flow_succ_size]
  have hpsz : C.fl.pad.size = C.fl.succ.size := (postFix_spec C.hlive).2.1
  have hkk : s.pc < C.fl.succ.size := by rw [hssz]; exact hlt
  have htin : pc' < S.c.d.insns.size → pc' ∈ C.fl.succ[s.pc]! := fun hyl => by
    rw [hsucc]; exact flow_succ_native hi hf hnc hp' hyl
  -- every byte of `P` the footprint reads is `Uninit` in `s1`
  have hrd : ∀ o, (∃ rg ∈ fp.readRanges (OpSem.opndVal f.info vals),
      OpSem.inRange o rg = true) → P o → s1.st.frame o = .uninit := by
    intro o hread hpo
    obtain ⟨hif, -, -, -⟩ := h.patch o hpo
    exact read_uninit C h hs1 hends hpo
      (gen_of_operand_mem hsub (hR fp hfp o hif.1 hif.2 hread))
  have hfeq : ∀ o, (∃ rg ∈ fp.readRanges (OpSem.opndVal f.info vals),
      OpSem.inRange o rg = true) → (eraseSt P s1.st).frame o = s1.st.frame o := by
    intro o hread
    by_cases hpo : P o
    · simp only [eraseSt, hpo, ↓reduceIte]
      exact (hrd o hread hpo).symm
    · simp only [eraseSt, hpo, ↓reduceIte]
  -- R's own `opSem`
  obtain ⟨⟨ctl2, stR⟩, ho2, hctl, hfr⟩ := opSem_erase (st := s1.st) hfp hrd ho
  simp only at hctl
  subst hctl
  have hsb : (eraseSt P s1.st).SameButFrame s1.st := ⟨rfl, rfl, rfl, rfl, rfl⟩
  have hexact : ∀ o, (∃ rg ∈ fp.writeRanges (OpSem.opndVal f.info vals),
      OpSem.inRange o rg = true) → st.frame o = stR.frame o :=
    h.fpExact f vals (eraseSt P s1.st) s1.st ch fp (ctl, st) (ctl, stR) hfp hsb hfeq ho ho2
  have hescR : stR.escaped = s1.st.escaped := (Ryo.Proofs.OpFacts.opSem_out ho2).2.1
  let s' : R.RState := { s1 with pc := pc', st := stR }
  have hRstep : R.step S.c s ch = .ok (.step s') := by
    rw [step_native_of hi hf hos hs1]
    exact stepView_native_of hview hres hun ho2 hp
  let Wr : Int → Prop := fun o => ∃ rg ∈ fp.writeRanges (OpSem.opndVal f.info vals),
    OpSem.inRange o rg = true
  let P' : Int → Prop := fun o => P o ∧ ¬ Wr o ∧ s'.st.escapedAt o = none ∧
    (Dead S C s'.pc o ∨ (s'.st.byteAt o = .ok .uninit ∧ CacheCovers S s'.pc o))
  have hfin : ∀ o, stR.frame o = st.frame o ∨
      (¬ Wr o ∧ stR.frame o = s1.st.frame o ∧ st.frame o = (eraseSt P s1.st).frame o) := by
    intro o
    by_cases hw : Wr o
    · exact .inl (hexact o hw).symm
    · have hno : ∀ rg ∈ fp.writeRanges (OpSem.opndVal f.info vals),
          OpSem.inRange o rg = false := by
        intro rg hrg
        cases hb : OpSem.inRange o rg
        · rfl
        · exact (hw ⟨rg, hrg, hb⟩).elim
      exact .inr ⟨hw, OpSem.opSem_frame_writes hfp ho2 o hno,
        OpSem.opSem_frame_writes hfp ho o hno⟩
  have hesc' : ∀ o, s'.st.escapedAt o = s1.st.escapedAt o := fun o => by
    show stR.escapedAt o = _
    unfold OpSem.State.escapedAt; rw [hescR]
  have hleave : ∀ o, P o → ¬ Wr o → ¬ P' o → s1.st.escapedAt o = none →
      s1.st.frame o = .uninit := by
    intro o hpo hnw hno hpr
    have hpr' : s'.st.escapedAt o = none := (hesc' o).trans hpr
    obtain ⟨hif, -, hpriv, hd⟩ := h.patch o hpo
    have hnd : ¬ Dead S C pc' o := fun hd' => hno ⟨hpo, hnw, hpr', .inl hd'⟩
    rcases hd with hdead | ⟨hb, -⟩
    · have hlive : (C.fl.liveIn[pc']!).testBit (bit S o) = true := by
        cases hb : (C.fl.liveIn[pc']!).testBit (bit S o)
        · exact (hnd ⟨hif, hb⟩).elim
        · rfl
      have hyl := lt_of_live C hlive
      have hkb : C.fl.kill[s.pc]!.bits.testBit (bit S o) = false := by
        rw [hkill]
        cases hkb : (Frame.Ranges.bits (Frame.Flow.opndRanges S.c.d.frameSize false eb
            (Frame.native op ops S.c.mode.pe (Frame.Flow.lendsOf (Frame.scopesAt S.c.d) s.pc)
              (C.facts.islandTemplate s.pc)).opnds).2).testBit (bit S o)
        · rfl
        · exact (hnw (hW fp hfp o hif.1 hif.2 hkb)).elim
      have hend : C.fl.ends[s.pc]!.bits.testBit (bit S o) = true := by
        cases he' : C.fl.ends[s.pc]!.bits.testBit (bit S o)
        · have := live_succ C.hlive hkk (htin hyl) hlive hkb
            (by rw [hun0]; simp [Frame.Ranges.bits]) he'
          rw [hdead.2] at this
          cases this
        · rfl
      rw [hends] at hend
      obtain ⟨sc, hsc', hk, h1, h2⟩ := end_scope_of_bit hif hend
      exact private_fold _ hs1 hpriv
        (fun sc hsc a hka hcov => not_dead_of_escape C hlt hsc hka hcov.1 hcov.2 hdead)
        (.inr ⟨sc, hsc', hk, h1, h2⟩)
    · refine foldlM_frame_uninit _ hs1 ?_
      simp only [OpSem.State.byteAt, hpriv] at hb
      exact Except.ok.inj hb
  have hkP : ∀ o, P' o → InFrame S o → C.fl.kill[s.pc]!.bits.testBit (bit S o) = false := by
    intro o ho hif
    rw [hkill]
    cases hkb : (Frame.Ranges.bits (Frame.Flow.opndRanges S.c.d.frameSize false eb
        (Frame.native op ops S.c.mode.pe (Frame.Flow.lendsOf (Frame.scopesAt S.c.d) s.pc)
          (C.facts.islandTemplate s.pc)).opnds).2).testBit (bit S o)
    · rfl
    · exact (ho.2.1 (hW fp hfp o hif.1 hif.2 hkb)).elim
  have hEU : ∀ o, P' o → InFrame S o → s'.pc ∈ C.fl.succ[s.pc]! →
      C.fl.ends[s.pc]!.bits.testBit (bit S o) = true → s'.st.byteAt o = .ok .uninit := by
    intro o ho _ _ heb
    refine byteAt_of_frame ho.2.2.1 ?_
    show stR.frame o = .uninit
    have hno : ∀ rg ∈ fp.writeRanges (OpSem.opndVal f.info vals),
        OpSem.inRange o rg = false := by
      intro rg hrg
      cases hb : OpSem.inRange o rg
      · rfl
      · exact (ho.2.1 ⟨rg, hrg, hb⟩).elim
    rw [OpSem.opSem_frame_writes hfp ho2 o hno]
    exact (ends_noGhost C h hs1 hends ho.1 heb).resolve_left
      (fun hne => hne ((hesc' o).symm.trans ho.2.2.1))
  refine ⟨s', P', fun o ho => ho.1, .inr hkP, hEU, RNext.step (ch := ch) hRstep, ⟨rfl, rfl, rfl, ?_⟩,
    fun o ho => ?_, fun o ho => ?_, ?_⟩
  · refine ⟨hfr.1.1.symm, hfr.1.2.2.2.2.symm, hfr.1.2.1.symm, hfr.1.2.2.1.symm,
      hfr.1.2.2.2.1.symm, fun o ho => ?_⟩
    have hpr : s1.st.escapedAt o = none := (hesc' o).symm.trans ho
    simp only [eraseSt]
    by_cases hp'o : P' o
    · simp only [hp'o, ↓reduceIte]
    · simp only [hp'o, ↓reduceIte]
      rcases hfin o with hq | ⟨hnw, h1, h2⟩
      · exact hq
      · rw [h1, h2]
        simp only [eraseSt]
        by_cases hpo : P o
        · simp only [hpo, ↓reduceIte]
          exact hleave o hpo hnw hp'o hpr
        · simp only [hpo, ↓reduceIte]
  · obtain ⟨hpo, hnw, hpr, -⟩ := ho
    have hpr1 : s1.st.escapedAt o = none := (hesc' o).symm.trans hpr
    have hn' : st.escapedAt o = none := by
      have hes : st.escaped = s1.st.escaped := hfr.1.1.trans hescR
      unfold OpSem.State.escapedAt; rw [hes]; exact hpr1
    show st.byteAt o = .ok .uninit
    simp only [OpSem.State.byteAt, hn']
    have hno : ∀ rg ∈ fp.writeRanges (OpSem.opndVal f.info vals),
        OpSem.inRange o rg = false := by
      intro rg hrg
      cases hb : OpSem.inRange o rg
      · rfl
      · exact (hnw ⟨rg, hrg, hb⟩).elim
    rw [OpSem.opSem_frame_writes hfp ho o hno]
    simp only [erase, eraseSt, hpo, ↓reduceIte]
    all_goals rfl
  · obtain ⟨hpo, -, hpr, hd⟩ := ho
    obtain ⟨hif, hdr, -, -⟩ := h.patch o hpo
    exact ⟨hif, hdr, hpr, hd⟩
  · intro hyl
    have hedge : pc' ∈ C.fl.edges[s.pc]! := by
      rw [flow_edges_get hkk (by rw [hpsz]; exact hkk)]
      exact List.mem_append_left _ (htin hyl)
    exact escPre_next C.hesc hlt h.esc hs1 hescR hedge

/-- T3c: a non-inline native `opSem` instruction (`op`, `br`, `switch`, `trap`, `lpad`
shapes). -/
theorem rnext_erase_native_op (C : Cert S) {s t' : R.RState} {P : Int → Prop}
    (h : StepPre S C s P) {op : Reduced.Opcode} {ops : List (Opnd Nat)} {f : Full.Opcode}
    (hi : S.c.d.insns[s.pc]? = some (.native op ops)) (hf : op.full = some f)
    (hsj : f.info.shape ≠ .jmp) (hsa : f.info.shape ≠ .arg) (hsi : f.info.shape ≠ .island)
    (hcall : f.info.shape ≠ .call ∧ f.info.shape ≠ .tailCall ∧ f.info.shape ≠ .ret)
    (hn : RNext S.c (erase s P) t') : StepOut S C s P t' :=
  rnext_erase_native_op' C h hi hf (opShape_of_ne hsj hsa hsi hcall) ⟨hcall.1, hcall.2.1⟩
    (fun t ctl y hc hs => h.nativeRange op ops f t ctl y hi hf hc hs) hn

/-! ### Islands: helpers (T3c) -/

/-- The same frame write on two states with the same escaped objects: equal where it writes a
private byte, unchanged elsewhere. -/
theorem writeFrame_pair {a b a' b' : OpSem.State} {off : Int} {bs : List AbstractByte}
    (he : a.escaped = b.escaped) (ha : a.writeFrame off bs = .ok a')
    (hb : b.writeFrame off bs = .ok b') :
    a'.escaped = a.escaped ∧ b'.escaped = b.escaped ∧ ∀ o,
      (a.privateIn off bs.length o = true → a'.frame o = b'.frame o) ∧
      (a.privateIn off bs.length o = false → a'.frame o = a.frame o ∧ b'.frame o = b.frame o) := by
  obtain ⟨_, -, -, hea, hfa⟩ := writeFrame_parts ha
  obtain ⟨_, -, -, heb, hfb⟩ := writeFrame_parts hb
  refine ⟨hea, heb, fun o => ⟨fun hp => ?_, fun hp => ?_⟩⟩
  · rw [hfa o, hfb o, ← privateIn_congr he _ _ o, hp]
    rfl
  · rw [hfa o, hfb o, ← privateIn_congr he _ _ o, hp]
    exact ⟨rfl, rfl⟩

/-- A fold of frame writes (as `writeRanges`'), on two states with the same escaped objects. -/
theorem fold_pair {F : OpSem.State → (Int × Nat) × List AbstractByte → OpSem.M OpSem.State}
    (hF : ∀ st p st', F st p = .ok st' → st.writeFrame p.1.1 p.2 = .ok st') :
    ∀ (L : List ((Int × Nat) × List AbstractByte)) (a b a' b' : OpSem.State),
      a.escaped = b.escaped → L.foldlM F a = .ok a' → L.foldlM F b = .ok b' →
      a'.escaped = a.escaped ∧ ∀ o,
        ((∃ p ∈ L, a.privateIn p.1.1 p.2.length o = true) → a'.frame o = b'.frame o) ∧
        ((∀ p ∈ L, a.privateIn p.1.1 p.2.length o = false) →
          a'.frame o = a.frame o ∧ b'.frame o = b.frame o)
  | [], a, b, a', b', _, ha, hb => by
    cases ha; cases hb
    refine ⟨rfl, fun o => ⟨?_, fun _ => ⟨rfl, rfl⟩⟩⟩
    rintro ⟨_, hp, _⟩
    cases hp
  | p :: L, a, b, a', b', he, ha, hb => by
    simp only [List.foldlM_cons, bind, Except.bind] at ha hb
    cases ha1 : F a p with
    | error e => rw [ha1] at ha; cases ha
    | ok a1 =>
      cases hb1 : F b p with
      | error e => rw [hb1] at hb; cases hb
      | ok b1 =>
        rw [ha1] at ha
        rw [hb1] at hb
        obtain ⟨hea1, heb1, hw⟩ := writeFrame_pair he (hF _ _ _ ha1) (hF _ _ _ hb1)
        have he1 : a1.escaped = b1.escaped := by rw [hea1, heb1, he]
        obtain ⟨he', ih⟩ := fold_pair hF L a1 b1 a' b' he1 ha hb
        have hpi : ∀ q : (Int × Nat) × List AbstractByte, ∀ o,
            a1.privateIn q.1.1 q.2.length o = a.privateIn q.1.1 q.2.length o :=
          fun q o => privateIn_congr hea1 _ _ o
        refine ⟨he'.trans hea1, fun o => ⟨fun ⟨q, hq, hqo⟩ => ?_, fun hno => ?_⟩⟩
        · by_cases hL : ∃ q ∈ L, a1.privateIn q.1.1 q.2.length o = true
          · exact (ih o).1 hL
          · have hL' : ∀ q ∈ L, a1.privateIn q.1.1 q.2.length o = false := by
              intro q hq
              cases hb' : a1.privateIn q.1.1 q.2.length o
              · rfl
              · exact (hL ⟨q, hq, hb'⟩).elim
            obtain ⟨h1, h2⟩ := (ih o).2 hL'
            rw [h1, h2]
            rcases List.mem_cons.1 hq with rfl | hq
            · exact (hw o).1 hqo
            · rw [← hpi q o] at hqo
              exact (hL ⟨q, hq, hqo⟩).elim
        · have hL' : ∀ q ∈ L, a1.privateIn q.1.1 q.2.length o = false := fun q hq => by
            rw [hpi q o]; exact hno q (List.mem_cons_of_mem _ hq)
          obtain ⟨h1, h2⟩ := (ih o).2 hL'
          obtain ⟨h3, h4⟩ := (hw o).2 (hno p (List.mem_cons_self ..))
          exact ⟨h1.trans h3, h2.trans h4⟩

/-- `writeRanges` on two states with the same escaped objects. -/
theorem writeRanges_pair {a b a' b' : OpSem.State} {rs : List (Int × Nat)}
    {new : List (List AbstractByte)} (he : a.escaped = b.escaped)
    (ha : R.writeRanges a rs new = .ok a') (hb : R.writeRanges b rs new = .ok b') :
    a'.escaped = a.escaped ∧ ∀ o,
      ((∃ p ∈ rs.zip new, a.privateIn p.1.1 p.2.length o = true) → a'.frame o = b'.frame o) ∧
      ((∀ p ∈ rs.zip new, a.privateIn p.1.1 p.2.length o = false) →
        a'.frame o = a.frame o ∧ b'.frame o = b.frame o) := by
  unfold R.writeRanges at ha hb
  by_cases hn : new.isEmpty = true
  · simp only [hn, ↓reduceIte, pure, Except.pure, Except.ok.injEq] at ha hb
    subst ha hb
    have : new = [] := List.isEmpty_iff.1 hn
    subst this
    refine ⟨rfl, fun o => ⟨?_, fun _ => ⟨rfl, rfl⟩⟩⟩
    rintro ⟨_, hp, _⟩
    simp at hp
  · simp only [hn, Bool.false_eq_true, ↓reduceIte] at ha hb
    by_cases hl : (new.length != rs.length) = true
    · simp only [hl, ↓reduceIte] at ha
      cases ha
    · simp only [hl, Bool.false_eq_true, ↓reduceIte] at ha hb
      refine fold_pair (fun st p st' h => ?_) _ a b a' b' he ha hb
      obtain ⟨⟨off, n⟩, bs⟩ := p
      simp only at h
      split at h
      · cases h
      · exact h

/-- A kill range of `opndRanges` comes from a `write` access. -/
theorem opndRanges_kill_aux (f : Nat) (isCall : Bool) (eb : Nat) :
    ∀ (L : List (BitVec 32 × Frame.Access)) (st : Frame.Ranges × Frame.Ranges) (r : Nat × Nat),
      r ∈ (L.foldl (Frame.Flow.opndStep f isCall eb) st).2 →
      r ∈ st.2 ∨ ∃ off m, (off, Frame.Access.write m) ∈ L ∧ r = Frame.range f off m
  | [], st, r, h => .inl h
  | x :: L, st, r, h => by
    rcases opndRanges_kill_aux f isCall eb L _ r h with h1 | ⟨off, m, hm, rfl⟩
    · obtain ⟨xo, acc⟩ := x
      cases acc with
      | write m =>
        simp only [Frame.Flow.opndStep] at h1
        rcases List.mem_cons.1 h1 with rfl | h1
        · exact .inr ⟨xo, m, List.mem_cons_self .., rfl⟩
        · exact .inl h1
      | addr =>
        simp only [Frame.Flow.opndStep] at h1
        split at h1 <;> exact .inl h1
      | _ =>
        simp only [Frame.Flow.opndStep] at h1
        exact .inl h1
    · exact .inr ⟨off, m, List.mem_cons_of_mem _ hm, rfl⟩

/-- A `Lend` extent of `Frame.scopesAt`'s row is one of R's `lendsAt`. -/
theorem lendsOf_mem {k : Nat} {off : BitVec 32} {n : Nat}
    (h : (off, n) ∈ Frame.Flow.lendsOf (Frame.scopesAt S.c.d) k) :
    (off.toInt, n) ∈ S.c.lendsAt k := by
  unfold Frame.Flow.lendsOf at h
  obtain ⟨⟨j, sc⟩, hjm, hjr⟩ := List.mem_filterMap.1 h
  have hsc := mem_scopesAt_of_frame hjm S.c rfl
  by_cases hk : sc.kind = .lend
  · simp [hk] at hjr
    obtain ⟨rfl, rfl⟩ := hjr
    unfold R.Code.lendsAt
    exact List.mem_filterMap.2 ⟨sc, hsc, by simp [hk]⟩
  · simp [hk] at hjr

theorem step_island_ok {c : R.Code} {s : R.RState} {ch : OpSem.Choice} {o : R.Out}
    {op : Reduced.Opcode} {f : Full.Opcode} {isl : Nat} {ws : List (BitVec 32)}
    (hi : c.d.insns[s.pc]? = some (.native op [.sym isl, .words ws])) (hf : op.full = some f)
    (hsh : f.info.shape = .island) (h : R.step c s ch = .ok o) :
    ∃ s1, (c.scopesAt s.pc).foldlM R.applyScope s = .ok s1 ∧
      o = .ext ⟨.island isl (c.islandTemplate s1.pc) s1.fp (ws.map (·.toInt)) (c.lendsAt s1.pc),
        s1.world⟩ s1 := by
  unfold R.step at h
  simp only [hi, bind, Except.bind] at h
  cases hsc : (c.scopesAt s.pc).foldlM R.applyScope s with
  | error e => simp [hsc] at h
  | ok s1 =>
    simp only [hsc, hf] at h
    rw [hsh] at h
    simp only [pure, Except.pure, Except.ok.injEq] at h
    exact ⟨s1, rfl, h.symm⟩

theorem step_island_of {c : R.Code} {s s1 : R.RState} {ch : OpSem.Choice}
    {op : Reduced.Opcode} {f : Full.Opcode} {isl : Nat} {ws : List (BitVec 32)}
    (hi : c.d.insns[s.pc]? = some (.native op [.sym isl, .words ws])) (hf : op.full = some f)
    (hsh : f.info.shape = .island) (hsc : (c.scopesAt s.pc).foldlM R.applyScope s = .ok s1) :
    R.step c s ch = .ok (.ext ⟨.island isl (c.islandTemplate s1.pc) s1.fp (ws.map (·.toInt))
      (c.lendsAt s1.pc), s1.world⟩ s1) := by
  unfold R.step
  simp only [hi, bind, Except.bind, hsc, hf]
  rw [hsh]
  all_goals rfl

/-- `answer` at an island: its writes, then the next instruction or unwinding. -/
theorem answer_island_ok {c : R.Code} {s : R.RState} {a : R.Answer} {o : R.Out}
    {op : Reduced.Opcode} {ops : List (Opnd Nat)} {f : Full.Opcode}
    (hi : c.d.insns[s.pc]? = some (.native op ops)) (hf : op.full = some f)
    (hsh : f.info.shape = .island) (h : R.answer c s a = .ok o) :
    ∃ st', c.islandWrites s.pc (s.withWorld a.world).st a.frame = .ok st' ∧
      ((∃ regs, a.result = .ret regs ∧
          o = .step { (s.withWorld a.world) with st := st', pc := s.pc + 1 }) ∨
        (∃ exc, a.result = .unwind exc ∧
          R.unwindAt c { (s.withWorld a.world) with st := st' } exc = .ok o)) := by
  unfold R.answer at h
  simp only [hi, hf, bind, Except.bind] at h
  rw [hsh] at h
  try dsimp only at h
  cases hw : c.islandWrites (s.withWorld a.world).pc (s.withWorld a.world).st a.frame with
  | error e => rw [hw] at h; cases h
  | ok st' =>
    rw [hw] at h
    try simp only at h
    refine ⟨st', hw, ?_⟩
    cases hr : a.result with
    | ret regs =>
      rw [hr] at h
      simp only [pure, Except.pure, Except.ok.injEq] at h
      exact .inl ⟨regs, rfl, h.symm⟩
    | unwind exc =>
      rw [hr] at h
      exact .inr ⟨exc, rfl, h⟩

/-! ### Islands: more helpers (T3c) -/

theorem flow_succ_next_island {d : Decoded} {k : Nat} {op : Reduced.Opcode}
    {ops : List (Opnd Nat)} (hi : d.insns[k]? = some (.native op ops))
    (hs : op.info.shape = .island) (hn : k + 1 < d.insns.size) : k + 1 ∈ (Frame.flow d).1[k]! := by
  have hk : k < d.insns.size := by omega
  unfold Frame.flow
  simp only [Id.run_bind, Id.run_pure, Std.Legacy.Range.forIn'_eq_forIn'_range',
    Std.Legacy.Range.size]
  refine forIn'_push_mem (R := fun a x => ∀ op ops, d.insns[a]? = some (.native op ops) →
    op.info.shape = .island → a + 1 < d.insns.size → a + 1 ∈ x) _ ?_ (by simpa using hk)
    (fun x hR => hR op ops hi hs hn)
  intro a h b
  refine ⟨_, rfl, ?_⟩
  intro op' ops' hop hs' hn'
  have hd : ∀ hh : a < d.insns.size, d.insns[a]'hh = .native op' ops' := fun hh => by
    rw [Array.getElem?_eq_getElem hh] at hop
    exact Option.some.inj hop
  simp only [hd]
  simp [hs', hn']

theorem islandWrites_parts {c : R.Code} {k : Nat} {st st' : OpSem.State}
    {new : List (List AbstractByte)} (h : c.islandWrites k st new = .ok st') :
    ∃ m, R.writeRanges st (c.lendsAt k) new = .ok m ∧
      m.writeFrame (-(c.d.frameSize : Int)) (List.replicate c.islandShadow .uninit) = .ok st' := by
  unfold R.Code.islandWrites at h
  simp only [bind, Except.bind] at h
  cases hw : R.writeRanges st (c.lendsAt k) new with
  | error e => rw [hw] at h; cases h
  | ok m => rw [hw] at h; exact ⟨m, rfl, h⟩

theorem fold_rel {f1 f2 : Int → AbstractByte}
    {F : OpSem.State → (Int × Nat) × List AbstractByte → OpSem.M OpSem.State}
    (hF : ∀ a b p, OpSem.FrameRel f1 f2 a b →
      OpSem.ResultRel (OpSem.FrameRel f1 f2) (F a p) (F b p)) :
    ∀ (L : List ((Int × Nat) × List AbstractByte)) (a b : OpSem.State),
      OpSem.FrameRel f1 f2 a b →
      OpSem.ResultRel (OpSem.FrameRel f1 f2) (L.foldlM F a) (L.foldlM F b)
  | [], a, b, h => h
  | p :: L, a, b, h => by
    simp only [List.foldlM_cons, bind, Except.bind]
    have h1 := hF a b p h
    revert h1
    cases F a p <;> cases F b p <;> simp only [OpSem.ResultRel, imp_self, false_implies]
    all_goals (intro hh; first | exact fold_rel hF L _ _ hh | (subst hh; rfl))

theorem writeRanges_rel {f1 f2 : Int → AbstractByte} {a b : OpSem.State}
    {rs : List (Int × Nat)} {new : List (List AbstractByte)} (h : OpSem.FrameRel f1 f2 a b) :
    OpSem.ResultRel (OpSem.FrameRel f1 f2) (R.writeRanges a rs new) (R.writeRanges b rs new) := by
  unfold R.writeRanges
  by_cases hn : new.isEmpty = true
  · simp only [hn, ↓reduceIte]
    exact h
  · simp only [hn, Bool.false_eq_true, ↓reduceIte]
    by_cases hl : (new.length != rs.length) = true
    · simp only [hl, ↓reduceIte]
      rfl
    · simp only [hl, Bool.false_eq_true, ↓reduceIte]
      refine fold_rel (fun x y p hxy => ?_) _ _ _ h
      obtain ⟨⟨off, n⟩, bs⟩ := p
      simp only
      split
      · rfl
      · exact OpSem.writeFrame_rel hxy

theorem islandWrites_rel {c : R.Code} {k : Nat} {f1 f2 : Int → AbstractByte}
    {a b : OpSem.State} {new : List (List AbstractByte)} (h : OpSem.FrameRel f1 f2 a b) :
    OpSem.ResultRel (OpSem.FrameRel f1 f2) (c.islandWrites k a new) (c.islandWrites k b new) := by
  unfold R.Code.islandWrites
  simp only [bind, Except.bind]
  have h1 := writeRanges_rel (rs := c.lendsAt k) (new := new) h
  revert h1
  cases R.writeRanges a (c.lendsAt k) new <;> cases R.writeRanges b (c.lendsAt k) new <;>
    simp only [OpSem.ResultRel, imp_self, false_implies]
  all_goals (intro hh; first | exact OpSem.writeFrame_rel hh | (subst hh; rfl))

theorem fold_lengths
    {F : OpSem.State → (Int × Nat) × List AbstractByte → OpSem.M OpSem.State}
    (hF : ∀ st p st', F st p = .ok st' → p.2.length = p.1.2) :
    ∀ (L : List ((Int × Nat) × List AbstractByte)) (x x' : OpSem.State),
      L.foldlM F x = .ok x' → ∀ p ∈ L, p.2.length = p.1.2
  | [], _, _, _, _, hp => by cases hp
  | q :: L, x, x', h, p, hp => by
    simp only [List.foldlM_cons, bind, Except.bind] at h
    cases hq : F x q with
    | error e => rw [hq] at h; cases h
    | ok x1 =>
      rw [hq] at h
      rcases List.mem_cons.1 hp with rfl | hp
      · exact hF _ _ _ hq
      · exact fold_lengths hF L x1 x' h p hp

/-- A successful `writeRanges` with bytes wrote each range's size. -/
theorem writeRanges_lengths {a a' : OpSem.State} {rs : List (Int × Nat)}
    {new : List (List AbstractByte)} (h : R.writeRanges a rs new = .ok a')
    (hne : new.isEmpty = false) :
    new.length = rs.length ∧ ∀ p ∈ rs.zip new, p.2.length = p.1.2 := by
  unfold R.writeRanges at h
  simp only [hne, Bool.false_eq_true, ↓reduceIte] at h
  by_cases hl : (new.length != rs.length) = true
  · simp only [hl, ↓reduceIte] at h
    cases h
  · simp only [hl, Bool.false_eq_true, ↓reduceIte] at h
    refine ⟨by simpa using hl, fold_lengths (fun st p st' hp => ?_) _ a a' h⟩
    obtain ⟨⟨off, n⟩, bs⟩ := p
    simp only at hp
    split at hp
    · cases hp
    · rename_i hq
      simpa using hq

/-! ### Islands: the step (T3c) -/

theorem answer_island_of {c : R.Code} {s : R.RState} {a : R.Answer} {st' : OpSem.State}
    {op : Reduced.Opcode} {ops : List (Opnd Nat)} {f : Full.Opcode}
    (hi : c.d.insns[s.pc]? = some (.native op ops)) (hf : op.full = some f)
    (hsh : f.info.shape = .island)
    (hw : c.islandWrites (s.withWorld a.world).pc (s.withWorld a.world).st a.frame = .ok st') :
    (∀ regs, a.result = .ret regs →
      R.answer c s a = .ok (.step { (s.withWorld a.world) with st := st', pc := s.pc + 1 })) ∧
    (∀ exc, a.result = .unwind exc →
      R.answer c s a = R.unwindAt c { (s.withWorld a.world) with st := st' } exc) := by
  unfold R.answer
  simp only [hi, hf, bind, Except.bind]
  rw [hsh]
  try dsimp only
  rw [hw]
  try simp only
  refine ⟨fun regs hr => ?_, fun exc hr => ?_⟩
  · rw [hr]; rfl
  · rw [hr]

theorem islandAccess_write {tmpl : Option String} {w : List (BitVec 32)} {o : BitVec 32}
    {n m : Nat} (h : Frame.islandAccess tmpl w o n = .write m) : m = n := by
  revert h
  unfold Frame.islandAccess
  cases tmpl with
  | none => intro h; cases h
  | some t =>
    try simp only
    split
    · intro h; cases h
    · split
      · intro h; cases h <;> rfl
      · intro h; cases h

/-- An island's frame operands: one per `Lend` extent, a write of the extent's size if any. -/
theorem native_island_opnds {op : Reduced.Opcode} (hs : op.info.shape = .island)
    (ops : List (Opnd Nat)) (pe : Bool) (lends : List (BitVec 32 × Nat)) (tmpl : Option String) :
    ∀ x ∈ (Frame.native op ops pe lends tmpl).opnds, ∃ y ∈ lends, x.1 = y.1 ∧
      ∀ m, x.2 = .write m → m = y.2 := by
  intro x hx
  simp only [Frame.native, hs] at hx
  obtain ⟨⟨o, n⟩, hy, rfl⟩ := List.mem_map.1 hx
  exact ⟨(o, n), hy, rfl, fun m hm => islandAccess_write hm⟩

theorem mem_zip_of_mem {α β : Type} {rs : List α} {new : List β} {x : α} (hx : x ∈ rs)
    (hl : new.length = rs.length) : ∃ b, (x, b) ∈ rs.zip new := by
  obtain ⟨i, hi, rfl⟩ := List.mem_iff_getElem.1 hx
  exact ⟨new[i]'(by omega), List.mem_iff_getElem.2 ⟨i, by simp; omega, by simp⟩⟩

/-- The common end of a step whose successor's frame equals the shadow's where `Wr` (what the
step writes) and is `s1`'s (the shadow's: erased) elsewhere. -/
theorem stepOut_core (C : Cert S) {s s1 s' t' : R.RState} {P : Int → Prop}
    (h : StepPre S C s P) (hRn : RNext S.c s s') (hpc : t'.pc = s'.pc) (hfp : s'.fp = t'.fp)
    (hargs : s'.args = t'.args) (hsb : s'.st.SameButFrame t'.st)
    (hesc : s'.st.escaped = s1.st.escaped) (Wr : Int → Prop)
    (hwr : ∀ o, Wr o → s'.st.frame o = t'.st.frame o)
    (hnw : ∀ o, ¬ Wr o → s'.st.frame o = s1.st.frame o ∧
      t'.st.frame o = (eraseSt P s1.st).frame o)
    (hleave : ∀ o, P o → ¬ Wr o → s1.st.escapedAt o = none → ¬ Dead S C s'.pc o →
      s1.st.frame o = .uninit)
    (hes : s'.pc < S.c.d.insns.size → EscSound S C s')
    (hkw : s'.pc ∈ C.fl.pad[s.pc]! ∨ ∀ o, P o → ¬ Wr o → s1.st.escapedAt o = none →
      InFrame S o → C.fl.kill[s.pc]!.bits.testBit (bit S o) = false)
    (hend : ∀ o, P o → ¬ Wr o → s1.st.escapedAt o = none → InFrame S o →
      s'.pc ∈ C.fl.succ[s.pc]! → C.fl.ends[s.pc]!.bits.testBit (bit S o) = true →
      s1.st.frame o = .uninit) : StepOut S C s P t' := by
  have hesc' : ∀ o, s'.st.escapedAt o = s1.st.escapedAt o := fun o => by
    unfold OpSem.State.escapedAt; rw [hesc]
  let P' : Int → Prop := fun o => P o ∧ ¬ Wr o ∧ s'.st.escapedAt o = none ∧
    (Dead S C s'.pc o ∨ (s'.st.byteAt o = .ok .uninit ∧ CacheCovers S s'.pc o))
  refine ⟨s', P', fun o ho => ho.1,
    hkw.imp id (fun hk o ho hif => hk o ho.1 ho.2.1 ((hesc' o).symm.trans ho.2.2.1) hif),
    fun o ho hif hsu heb => byteAt_of_frame ho.2.2.1 (by
      rw [(hnw o ho.2.1).1]
      exact hend o ho.1 ho.2.1 ((hesc' o).symm.trans ho.2.2.1) hif hsu heb),
    hRn, ⟨hpc.symm, hfp, hargs, ?_⟩, fun o ho => ?_, fun o ho => ?_, hes⟩
  · refine ⟨hsb.1, hsb.2.2.2.2, hsb.2.1, hsb.2.2.1, hsb.2.2.2.1, fun o ho => ?_⟩
    have hpr : s1.st.escapedAt o = none := (hesc' o).symm.trans ho
    simp only [eraseSt]
    by_cases hp'o : P' o
    · simp only [hp'o, ↓reduceIte]
    · simp only [hp'o, ↓reduceIte]
      by_cases hw : Wr o
      · exact hwr o hw
      · obtain ⟨h1, h2⟩ := hnw o hw
        rw [h1, h2]
        simp only [eraseSt]
        by_cases hpo : P o
        · simp only [hpo, ↓reduceIte]
          exact hleave o hpo hw hpr (fun hd => hp'o ⟨hpo, hw, (hesc' o).trans hpr, .inl hd⟩)
        · simp only [hpo, ↓reduceIte]
  · obtain ⟨hpo, hnw', hpr, -⟩ := ho
    have hpr1 : s1.st.escapedAt o = none := (hesc' o).symm.trans hpr
    have hn' : t'.st.escapedAt o = none := by
      unfold OpSem.State.escapedAt; rw [← hsb.1, hesc]; exact hpr1
    simp only [OpSem.State.byteAt, hn']
    rw [(hnw o hnw').2]
    simp only [eraseSt, hpo, ↓reduceIte]
    all_goals rfl
  · obtain ⟨hpo, -, hpr, hd⟩ := ho
    obtain ⟨hif, hdr, -, -⟩ := h.patch o hpo
    exact ⟨hif, hdr, hpr, hd⟩

/-- T3c: an island, its fall-through in range (`islandNext`) and its pad (`padRange`). -/
theorem rnext_erase_island' (C : Cert S) {s t' : R.RState} {P : Int → Prop}
    (h : StepPre S C s P) {op : Reduced.Opcode} {f : Full.Opcode} {isl : Nat}
    {ws : List (BitVec 32)}
    (hi : S.c.d.insns[s.pc]? = some (.native op [.sym isl, .words ws])) (hf : op.full = some f)
    (hsi : f.info.shape = .island)
    (hans : ∀ ch q s1 a, R.step S.c (erase s P) ch = .ok (.ext q s1) →
      R.answer S.c s1 a = .ok (.step t') → AnswerOk S s a)
    (hnx : s.pc + 1 ≤ S.c.d.insns.size) (hn : RNext S.c (erase s P) t') : StepOut S C s P t' := by
  have hi' : S.c.d.insns[(erase s P).pc]? = some (.native op [.sym isl, .words ws]) := hi
  -- only an answer
  obtain ⟨ch, q, t1, a, hstep, ha⟩ : ∃ ch q t1 a, R.step S.c (erase s P) ch = .ok (.ext q t1) ∧
      R.answer S.c t1 a = .ok (.step t') := by
    cases hn with
    | step hs =>
      obtain ⟨_, _, hc⟩ := step_island_ok hi' hf hsi hs
      cases hc
    | answer hs ha => exact ⟨_, _, _, _, hs, ha⟩
  have hok := hans ch q t1 a hstep ha
  obtain ⟨t1', hsc, hq⟩ := step_island_ok hi' hf hsi hstep
  cases hq
  obtain ⟨s1, hs1, rfl⟩ := scopes_erase_eq C h hsc
  have hpc : s1.pc = s.pc := (Ryo.Proofs.Scope.scopes_keeps _ hs1).pc
  have hlt := h.lt
  have hi1 : S.c.d.insns[(erase s1 P).pc]? = some (.native op [.sym isl, .words ws]) := by
    show S.c.d.insns[s1.pc]? = _
    rw [hpc]; exact hi
  have hiR : S.c.d.insns[s1.pc]? = some (.native op [.sym isl, .words ws]) := hi1
  obtain ⟨stSh, hwSh, hres⟩ := answer_island_ok hi1 hf hsi ha
  -- R's own island writes
  let sh0 := ((erase s1 P).withWorld a.world).st
  let r0 := (s1.withWorld a.world).st
  have hrel0 : OpSem.FrameRel (eraseSt P s1.st).frame s1.st.frame sh0 r0 :=
    ⟨⟨rfl, rfl, rfl, rfl, rfl⟩, fun o => .inr ⟨rfl, rfl⟩⟩
  have hrr := islandWrites_rel (c := S.c) (k := s1.pc) (new := a.frame) hrel0
  have hwSh' : S.c.islandWrites s1.pc sh0 a.frame = .ok stSh := hwSh
  rw [hwSh'] at hrr
  obtain ⟨stR, hwR⟩ : ∃ stR, S.c.islandWrites s1.pc r0 a.frame = .ok stR := by
    cases hwR : S.c.islandWrites s1.pc r0 a.frame with
    | error e => rw [hwR] at hrr; simp only [OpSem.ResultRel] at hrr
    | ok stR => exact ⟨stR, rfl⟩
  rw [hwR] at hrr
  have hsbR : stR.SameButFrame stSh :=
    ⟨hrr.1.1.symm, hrr.1.2.1.symm, hrr.1.2.2.1.symm, hrr.1.2.2.2.1.symm, hrr.1.2.2.2.2.symm⟩
  -- byte by byte
  obtain ⟨shm, hshR, hshF⟩ := islandWrites_parts hwSh'
  obtain ⟨rm, hrR, hrF⟩ := islandWrites_parts hwR
  obtain ⟨he1, hw1⟩ := writeRanges_pair (a := sh0) (b := r0) rfl hshR hrR
  have he1' : shm.escaped = rm.escaped := by
    rw [he1, (writeRanges_pair (a := r0) (b := sh0) rfl hrR hshR).1]; rfl
  obtain ⟨he2, -, hw2⟩ := writeFrame_pair he1' hshF hrF
  let Wr : Int → Prop := fun o =>
    (∃ p ∈ (S.c.lendsAt s1.pc).zip a.frame, sh0.privateIn p.1.1 p.2.length o = true) ∨
      shm.privateIn (-(S.c.d.frameSize : Int))
        (List.replicate S.c.islandShadow AbstractByte.uninit).length o = true
  have hwr : ∀ o, Wr o → stR.frame o = stSh.frame o := by
    intro o hwo
    by_cases hsh : shm.privateIn (-(S.c.d.frameSize : Int))
        (List.replicate S.c.islandShadow AbstractByte.uninit).length o = true
    · exact ((hw2 o).1 hsh).symm
    · have hsh' : shm.privateIn (-(S.c.d.frameSize : Int))
          (List.replicate S.c.islandShadow AbstractByte.uninit).length o = false := by
        cases hb : shm.privateIn (-(S.c.d.frameSize : Int))
          (List.replicate S.c.islandShadow AbstractByte.uninit).length o
        · rfl
        · exact (hsh hb).elim
      rcases hwo with hl | hl
      · obtain ⟨h1, h2⟩ := (hw2 o).2 hsh'
        rw [h1, h2]
        exact ((hw1 o).1 hl).symm
      · exact (hsh hl).elim
  have hnw : ∀ o, ¬ Wr o → stR.frame o = s1.st.frame o ∧
      stSh.frame o = (eraseSt P s1.st).frame o := by
    intro o hwo
    have hsh' : shm.privateIn (-(S.c.d.frameSize : Int))
        (List.replicate S.c.islandShadow AbstractByte.uninit).length o = false := by
      cases hb : shm.privateIn (-(S.c.d.frameSize : Int))
        (List.replicate S.c.islandShadow AbstractByte.uninit).length o
      · rfl
      · exact (hwo (.inr hb)).elim
    have hl' : ∀ p ∈ (S.c.lendsAt s1.pc).zip a.frame,
        sh0.privateIn p.1.1 p.2.length o = false := by
      intro p hp
      cases hb : sh0.privateIn p.1.1 p.2.length o
      · rfl
      · exact (hwo (.inl ⟨p, hp, hb⟩)).elim
    obtain ⟨h1, h2⟩ := (hw2 o).2 hsh'
    obtain ⟨h3, h4⟩ := (hw1 o).2 hl'
    exact ⟨h2.trans h4, h1.trans h3⟩
  have hescR : stR.escaped = s1.st.escaped := by
    rw [(writeFrame_pair he1'.symm hrF hshF).1, (writeRanges_pair (a := r0) (b := sh0) rfl hrR hshR).1]
    rfl
  -- the row
  have hshr := reduced_shape hf
  have hc1 : (op.info.shape == .call) = false := by rw [hshr, hsi]; rfl
  have hc2 : (op.info.shape == .tailCall) = false := by rw [hshr, hsi]; rfl
  have hni : (op.full.bind Asm.classOf).isSome = false := by
    cases hb : (op.full.bind Asm.classOf).isSome
    · rfl
    · exact (h.notInline ⟨op, _, hi, hb⟩).elim
  obtain ⟨eb, hkill, hun0, -, hends⟩ := flowOf_native_row C.hfl hi hni hc1 hc2
  have hsucc : C.fl.succ = (Frame.flow S.c.d).1 := flowOf_succ C.hfl
  have hssz : C.fl.succ.size = S.c.d.insns.size := by rw [hsucc, flow_succ_size]
  have hpsz : C.fl.pad.size = C.fl.succ.size := (postFix_spec C.hlive).2.1
  have hkk : s.pc < C.fl.succ.size := by rw [hssz]; exact hlt
  -- an unwritten byte of `P` isn't killed
  have hkb : ∀ o, P o → ¬ Wr o → s1.st.escapedAt o = none →
      C.fl.kill[s.pc]!.bits.testBit (bit S o) = false := by
    intro o hpo hwo hpr
    obtain ⟨⟨hf1, hf2⟩, -, -, -⟩ := h.patch o hpo
    rw [hkill]
    cases hb : (Frame.Ranges.bits (Frame.Flow.opndRanges S.c.d.frameSize false eb
        (Frame.native op [.sym isl, .words ws] S.c.mode.pe
          (Frame.Flow.lendsOf (Frame.scopesAt S.c.d) s.pc)
          (C.facts.islandTemplate s.pc)).opnds).2).testBit (bit S o)
    · rfl
    · exfalso
      rw [testBit_rangesBits] at hb
      obtain ⟨r, hr, hri⟩ := List.any_eq_true.1 hb
      rcases opndRanges_kill_aux _ _ _ _ ([], []) r hr with hr | ⟨off, m, hm, rfl⟩
      · cases hr
      obtain ⟨⟨off', n'⟩, hy, hoff, hmn⟩ := native_island_opnds (hshr.trans hsi) [.sym isl, .words ws]
        S.c.mode.pe (Frame.Flow.lendsOf (Frame.scopesAt S.c.d) s.pc)
        (C.facts.islandTemplate s.pc) _ hm
      simp only at hoff
      subst hoff
      have hmn' := hmn m rfl
      simp only at hmn'
      subst hmn'
      have hlend := lendsOf_mem hy
      rw [← hpc] at hlend
      have hlen : a.frame.length = (S.c.lendsAt s1.pc).length := by
        rw [hpc]; exact hok.1 op isl ws hi
      have hne : a.frame.isEmpty = false := by
        cases hfr : a.frame with
        | nil =>
          rw [hfr] at hlen
          have : (S.c.lendsAt s1.pc) = [] := List.eq_nil_of_length_eq_zero (by simpa using hlen.symm)
          rw [this] at hlend
          cases hlend
        | cons _ _ => rfl
      obtain ⟨-, hlens⟩ := writeRanges_lengths hshR hne
      obtain ⟨bs, hbs⟩ := mem_zip_of_mem hlend hlen
      have hbl := hlens _ hbs
      simp only at hbl
      simp only [Bool.and_eq_true, decide_eq_true_eq] at hri
      obtain ⟨hr1, hr2⟩ := hri
      simp only [Frame.range, bit] at hr1 hr2
      apply hwo
      refine .inl ⟨_, hbs, ?_⟩
      have hsh0 : sh0.escapedAt o = none := hpr
      unfold OpSem.State.privateIn
      rw [hsh0, hbl]
      simp only [Option.isNone_none, Bool.and_true, decide_eq_true_eq]
      omega
  -- a byte of `P` dead into `pc` and live into the successor `pc'` holds no ghost value
  have hleave_of : ∀ pc', (∀ o, P o → ¬ Wr o → s1.st.escapedAt o = none →
      (C.fl.liveIn[pc']!).testBit (bit S o) = true →
      (C.fl.liveIn[s.pc]!).testBit (bit S o) = true ∨
        C.fl.ends[s.pc]!.bits.testBit (bit S o) = true) →
      ∀ o, P o → ¬ Wr o → s1.st.escapedAt o = none → ¬ Dead S C pc' o →
        s1.st.frame o = .uninit := by
    intro pc' hlv o hpo hwo hpr hnd
    obtain ⟨hif, -, hpriv, hd⟩ := h.patch o hpo
    rcases hd with hdead | ⟨hb, -⟩
    · have hlive : (C.fl.liveIn[pc']!).testBit (bit S o) = true := by
        cases hb : (C.fl.liveIn[pc']!).testBit (bit S o)
        · exact (hnd ⟨hif, hb⟩).elim
        · rfl
      rcases hlv o hpo hwo hpr hlive with hl | hend
      · rw [hdead.2] at hl; cases hl
      rw [hends] at hend
      obtain ⟨sc, hsc', hk, h1, h2⟩ := end_scope_of_bit hif hend
      exact private_fold _ hs1 hpriv
        (fun sc hsc a hka hcov => not_dead_of_escape C hlt hsc hka hcov.1 hcov.2 hdead)
        (.inr ⟨sc, hsc', hk, h1, h2⟩)
    · refine foldlM_frame_uninit _ hs1 ?_
      simp only [OpSem.State.byteAt, hpriv] at hb
      exact Except.ok.inj hb
  have hedges := flow_edges_get hkk (by rw [hpsz]; exact hkk)
  obtain ⟨hRret, hRunw⟩ := answer_island_of hiR hf hsi hwR
  rcases hres with ⟨regs, hr, ht⟩ | ⟨exc, hr, hunw⟩
  · -- the next instruction
    cases ht
    have htin : s.pc + 1 < S.c.d.insns.size → s.pc + 1 ∈ C.fl.succ[s.pc]! := fun hyl => by
      rw [hsucc]; exact flow_succ_next_island hi (hshr.trans hsi) hyl
    have hRn : RNext S.c s { (s1.withWorld a.world) with st := stR, pc := s1.pc + 1 } :=
      RNext.answer (step_island_of (ch := ch) hi hf hsi hs1) (hRret regs hr)
    refine stepOut_core C h hRn rfl rfl rfl hsbR hescR Wr hwr hnw ?_ ?_
      (.inr fun o hpo hwo hpr _ => hkb o hpo hwo hpr)
      (fun o hpo _ hpr _ _ heb => (ends_noGhost C h hs1 hends hpo heb).resolve_left
        (fun hne => hne hpr))
    · intro o hpo hwo hpr hnd
      have hnd' : ¬ Dead S C (s.pc + 1) o := by rw [← hpc]; exact hnd
      refine hleave_of (s.pc + 1) (fun o hpo hwo hpr hl => ?_) o hpo hwo hpr hnd'
      cases he' : C.fl.ends[s.pc]!.bits.testBit (bit S o)
      · exact .inl (live_succ C.hlive hkk (htin (lt_of_live C hl)) hl (hkb o hpo hwo hpr)
          (by rw [hun0]; simp [Frame.Ranges.bits]) he')
      · exact .inr rfl
    · intro hyl
      have hedge : s.pc + 1 ∈ C.fl.edges[s.pc]! := by
        rw [hedges]; exact List.mem_append_left _ (htin (by rw [← hpc]; exact hyl))
      unfold EscSound
      show EscPre S.c.d C.fl.esc (s1.pc + 1) stR
      rw [hpc]
      exact escPre_next C.hesc hlt h.esc hs1 hescR hedge
  · -- unwinding
    unfold R.unwindAt at hunw
    cases hcl : S.c.cleanupAt ({ ((erase s1 P).withWorld a.world) with st := stSh }).pc with
    | none => rw [hcl] at hunw; simp [OpSem.ub, throw, throwThe, MonadExceptOf.throw] at hunw
    | some cb =>
      obtain ⟨opad, b⟩ := cb
      cases opad with
      | none =>
        rw [hcl] at hunw
        simp only [pure, Except.pure, Except.ok.injEq] at hunw
        cases hunw
      | some pad =>
        rw [hcl] at hunw
        simp only [pure, Except.pure, Except.ok.injEq, R.Out.step.injEq] at hunw
        subst hunw
        have hcl' : S.c.cleanupAt s.pc = some (some pad, b) := by rw [← hpc]; exact hcl
        have hpin : pad ∈ C.fl.pad[s.pc]! := by
          rw [flowOf_pad C.hfl]; exact flow_pad_mem hcl' hlt (h.padRange pad b hcl')
        have hRu : R.unwindAt S.c { (s1.withWorld a.world) with st := stR } exc =
            .ok (.step { (s1.withWorld a.world) with pc := pad, st := { stR with exception := exc } }) := by
          unfold R.unwindAt
          have hcl2 : S.c.cleanupAt (s1.withWorld a.world).pc = some (some pad, b) := hcl
          simp only [hcl2]
          all_goals rfl
        have hRn : RNext S.c s
            { (s1.withWorld a.world) with pc := pad, st := { stR with exception := exc } } :=
          RNext.answer (step_island_of (ch := ch) hi hf hsi hs1) ((hRunw exc hr).trans hRu)
        refine stepOut_core C h hRn rfl rfl rfl
          ⟨hsbR.1, hsbR.2.1, hsbR.2.2.1, rfl, hsbR.2.2.2.2⟩ hescR Wr hwr hnw ?_ ?_
          (.inl hpin)
          (fun o hpo _ hpr _ _ heb => (ends_noGhost C h hs1 hends hpo heb).resolve_left
            (fun hne => hne hpr))
        · refine hleave_of pad (fun o hpo hwo hpr hl => ?_)
          cases he' : C.fl.ends[s.pc]!.bits.testBit (bit S o)
          · exact .inl (live_pad C.hlive hkk hpin hl
              (by rw [hun0]; simp [Frame.Ranges.bits]) he')
          · exact .inr rfl
        · intro _
          have hedge : pad ∈ C.fl.edges[s.pc]! := by
            rw [hedges]; exact List.mem_append_right _ hpin
          exact escPre_next C.hesc hlt h.esc hs1 hescR hedge

/-- T3c: an island. -/
theorem rnext_erase_island (C : Cert S) {s t' : R.RState} {P : Int → Prop}
    (h : StepPre S C s P) {op : Reduced.Opcode} {f : Full.Opcode} {isl : Nat}
    {ws : List (BitVec 32)}
    (hi : S.c.d.insns[s.pc]? = some (.native op [.sym isl, .words ws])) (hf : op.full = some f)
    (hsi : f.info.shape = .island)
    (hans : ∀ ch q s1 a, R.step S.c (erase s P) ch = .ok (.ext q s1) →
      R.answer S.c s1 a = .ok (.step t') → AnswerOk S s a)
    (hn : RNext S.c (erase s P) t') : StepOut S C s P t' :=
  rnext_erase_island' C h hi hf hsi hans (h.islandNext op f isl ws hi hf hsi) hn

/-! ### Calls (T3b) -/

/-- A successful step of a call, tail call or `ret` native has that shape's operands. -/
theorem step_call_shape {c : R.Code} {s : R.RState} {ch : OpSem.Choice} {o : R.Out}
    {op : Reduced.Opcode} {ops : List (Opnd Nat)} {f : Full.Opcode}
    (hi : c.d.insns[s.pc]? = some (.native op ops)) (hf : op.full = some f)
    (h : R.step c s ch = .ok o) :
    (f.info.shape = .call → ∃ d fo k ws, ops = [.slot d, fo, .imm k, .words ws]) ∧
    (f.info.shape = .tailCall → ∃ fo ws, ops = [fo, .words ws]) ∧
    (f.info.shape = .ret → ∃ src k, ops = [.slot src, .imm k]) := by
  unfold R.step at h
  simp only [hi, bind, Except.bind] at h
  cases hsc : (c.scopesAt s.pc).foldlM R.applyScope s with
  | error e => simp [hsc] at h
  | ok s1 =>
    simp only [hsc, hf] at h
    refine ⟨fun hs => ?_, fun hs => ?_, fun hs => ?_⟩ <;> rw [hs] at h <;> (try dsimp only at h) <;>
      split at h <;>
      first
      | exact ⟨_, _, rfl⟩
      | exact ⟨_, _, _, _, rfl⟩
      | (exfalso; simp_all only [reduceCtorEq]; done)
      | (simp [OpSem.illFormed, throw, throwThe, MonadExceptOf.throw] at h; done)

/-- A successful step of a tail call: the scopes, the callee, the argument registers, the stack
arguments, and the end of the function. -/
theorem step_tailCall_done {c : R.Code} {s : R.RState} {ch : OpSem.Choice} {op : Reduced.Opcode}
    {fo : Opnd Nat} {ws : List (BitVec 32)} {f : Full.Opcode} {o : R.Out}
    (hi : c.d.insns[s.pc]? = some (.native op [fo, .words ws]))
    (hf : op.full = some f) (hsh : f.info.shape = .tailCall) (h : R.step c s ch = .ok o) :
    ∃ s1 cal regs stack, (c.scopesAt s.pc).foldlM R.applyScope s = .ok s1 ∧
      R.callee s1.st f fo = .ok cal ∧ R.argRegs s1.st ws = .ok regs ∧
      s1.st.readFrame 16 (c.stackSize s1.pc) = .ok stack ∧
      o = .done (R.exit s1 (.tailCall cal regs (s1.fp + 16) stack)) := by
  unfold R.step at h
  simp only [hi, bind, Except.bind] at h
  cases hsc : (c.scopesAt s.pc).foldlM R.applyScope s with
  | error e => simp [hsc] at h
  | ok s1 =>
    simp only [hsc, hf, hsh] at h
    cases hc : R.callee s1.st f fo with
    | error e => simp [hc] at h
    | ok cal =>
    simp only [hc] at h
    cases ha : R.argRegs s1.st ws with
    | error e => simp [ha] at h
    | ok regs =>
    simp only [ha] at h
    cases hrd : s1.st.readFrame 16 (c.stackSize s1.pc) with
    | error e => simp [hrd] at h
    | ok stack =>
    simp only [hrd, pure, Except.pure, Except.ok.injEq] at h
    exact ⟨s1, cal, regs, stack, rfl, hc, ha, hrd, h.symm⟩

/-- A call's sret write (`R.step`'s): the destination made `Uninit` for `sretSize` bytes, if
both are known; else nothing. -/
def SretW (c : R.Code) (k : Nat) (ws : List (BitVec 32)) (st st' : OpSem.State) : Prop :=
  (∃ n dst, c.sretSize k = some n ∧ Frame.sretDest ws = some dst ∧
    st.writeFrame dst.toInt (List.replicate n .uninit) = .ok st') ∨
  ((∀ n dst, c.sretSize k = some n → Frame.sretDest ws = some dst → False) ∧ st' = st)

/-- A successful step of a call (in or out of PE's pad region). -/
theorem step_call_ok {c : R.Code} {s : R.RState} {ch : OpSem.Choice} {op : Reduced.Opcode}
    {dd : BitVec 32} {fo : Opnd Nat} {k : BitVec 64} {ws : List (BitVec 32)} {f : Full.Opcode}
    {o : R.Out}
    (hi : c.d.insns[s.pc]? = some (.native op [.slot dd, fo, .imm k, .words ws]))
    (hf : op.full = some f) (hsh : f.info.shape = .call) (h : R.step c s ch = .ok o) :
    ∃ s1 parts cal regs sp stack st', (c.scopesAt s.pc).foldlM R.applyScope s = .ok s1 ∧
      R.retRegs k.toNat false = .ok parts ∧ R.callee s1.st f fo = .ok cal ∧
      R.argRegs s1.st ws = .ok regs ∧
      (c.inRegion s1.pc = true → sp = ch.sp ∧
        stack = List.replicate (c.stackSize s1.pc) AbstractByte.uninit) ∧
      (c.inRegion s1.pc = false → R.frameAddr s1.fp (-(c.d.frameSize : Int)) = .ok sp ∧
        s1.st.readFrame (-(c.d.frameSize : Int)) (c.stackSize s1.pc) = .ok stack) ∧
      SretW c s1.pc ws s1.st st' ∧
      o = .ext ⟨.call cal regs sp stack, ({ s1 with st := st' } : R.RState).world⟩
        { s1 with st := st' } := by
  unfold R.step at h
  simp only [hi, bind, Except.bind] at h
  cases hsc : (c.scopesAt s.pc).foldlM R.applyScope s with
  | error e => simp [hsc] at h
  | ok s1 =>
    simp only [hsc, hf, hsh] at h
    cases hp : R.retRegs k.toNat false with
    | error e => simp [hp] at h
    | ok parts =>
    simp only [hp] at h
    cases hc : R.callee s1.st f fo with
    | error e => simp [hc] at h
    | ok cal =>
    simp only [hc] at h
    cases ha : R.argRegs s1.st ws with
    | error e => simp [ha] at h
    | ok regs =>
    simp only [ha] at h
    by_cases hreg : c.inRegion s1.pc = true
    · simp only [hreg, ↓reduceIte, pure, Except.pure] at h
      split at h
      · rename_i n dst _ _
        cases hw : s1.st.writeFrame dst.toInt (List.replicate n .uninit) with
        | error e => simp [hw] at h
        | ok st' =>
          simp only [hw, Except.ok.injEq] at h
          exact ⟨s1, parts, cal, regs, ch.sp, List.replicate (c.stackSize s1.pc) .uninit, st',
            rfl, rfl, hc, ha, fun _ => ⟨rfl, rfl⟩, (fun h' => by rw [hreg] at h'; cases h'),
            Or.inl ⟨n, dst, by assumption, by assumption, hw⟩, h.symm⟩
      · simp only [Except.ok.injEq] at h
        exact ⟨s1, parts, cal, regs, ch.sp, List.replicate (c.stackSize s1.pc) .uninit, s1.st,
          rfl, rfl, hc, ha, fun _ => ⟨rfl, rfl⟩, (fun h' => by rw [hreg] at h'; cases h'),
          Or.inr ⟨by assumption, rfl⟩, h.symm⟩
    · have hreg' : c.inRegion s1.pc = false := by simpa using hreg
      simp only [hreg', Bool.false_eq_true, ↓reduceIte] at h
      cases hfa : R.frameAddr s1.fp (-(c.d.frameSize : Int)) with
      | error e => simp [hfa] at h
      | ok sp =>
      simp only [hfa] at h
      cases hrd : s1.st.readFrame (-(c.d.frameSize : Int)) (c.stackSize s1.pc) with
      | error e => simp [hrd] at h
      | ok stack =>
      simp only [hrd] at h
      split at h
      · rename_i n dst _ _
        cases hw : s1.st.writeFrame dst.toInt (List.replicate n .uninit) with
        | error e => simp [hw] at h
        | ok st' =>
          simp only [hw, pure, Except.pure, Except.ok.injEq] at h
          exact ⟨s1, parts, cal, regs, sp, stack, st', rfl, rfl, hc, ha,
            (fun h' => by rw [hreg'] at h'; cases h'), fun _ => ⟨hfa, hrd⟩,
            Or.inl ⟨n, dst, by assumption, by assumption, hw⟩, h.symm⟩
      · simp only [pure, Except.pure, Except.ok.injEq] at h
        exact ⟨s1, parts, cal, regs, sp, stack, s1.st, rfl, rfl, hc, ha,
          (fun h' => by rw [hreg'] at h'; cases h'), fun _ => ⟨hfa, hrd⟩,
          Or.inr ⟨by assumption, rfl⟩, h.symm⟩

/-- A call's step from its parts. -/
theorem step_call_of {c : R.Code} {s s1 : R.RState} {ch : OpSem.Choice} {op : Reduced.Opcode}
    {dd : BitVec 32} {fo : Opnd Nat} {k : BitVec 64} {ws : List (BitVec 32)} {f : Full.Opcode}
    {parts : List (Asm.RetPart × R.Reg)} {cal : R.Callee} {regs : R.Regs} {sp : Nat}
    {stack : List AbstractByte} {st' : OpSem.State}
    (hi : c.d.insns[s.pc]? = some (.native op [.slot dd, fo, .imm k, .words ws]))
    (hf : op.full = some f) (hsh : f.info.shape = .call)
    (hsc : (c.scopesAt s.pc).foldlM R.applyScope s = .ok s1)
    (hp : R.retRegs k.toNat false = .ok parts) (hc : R.callee s1.st f fo = .ok cal)
    (ha : R.argRegs s1.st ws = .ok regs)
    (hR1 : c.inRegion s1.pc = true → sp = ch.sp ∧
      stack = List.replicate (c.stackSize s1.pc) AbstractByte.uninit)
    (hR2 : c.inRegion s1.pc = false → R.frameAddr s1.fp (-(c.d.frameSize : Int)) = .ok sp ∧
      s1.st.readFrame (-(c.d.frameSize : Int)) (c.stackSize s1.pc) = .ok stack)
    (hw : SretW c s1.pc ws s1.st st') :
    R.step c s ch = .ok (.ext ⟨.call cal regs sp stack, ({ s1 with st := st' } : R.RState).world⟩
      { s1 with st := st' }) := by
  unfold R.step
  simp only [hi, bind, Except.bind, hsc, hf, hsh, hp, hc, ha]
  unfold SretW at hw
  by_cases hreg : c.inRegion s1.pc = true
  · obtain ⟨rfl, rfl⟩ := hR1 hreg
    simp only [hreg, ↓reduceIte, pure, Except.pure]
    rcases hw with ⟨n, dst, hn, hdst, hwr⟩ | ⟨hno, rfl⟩
    · simp only [hn, hdst, hwr]
    · cases hn : c.sretSize s1.pc with
      | none => cases hdst : Frame.sretDest ws <;> simp only [hn, hdst]
      | some n =>
        cases hdst : Frame.sretDest ws with
        | none => simp only [hn, hdst]
        | some dst => exact (hno n dst hn hdst).elim
  · have hreg' : c.inRegion s1.pc = false := by simpa using hreg
    obtain ⟨hfa, hrd⟩ := hR2 hreg'
    simp only [hreg', Bool.false_eq_true, ↓reduceIte, hfa, hrd]
    rcases hw with ⟨n, dst, hn, hdst, hwr⟩ | ⟨hno, rfl⟩
    · simp only [hn, hdst, hwr]
      all_goals rfl
    · cases hn : c.sretSize s1.pc with
      | none =>
        cases hdst : Frame.sretDest ws <;> simp only [hn, hdst] <;> rfl
      | some n =>
        cases hdst : Frame.sretDest ws with
        | none =>
          simp only [hn, hdst]
          all_goals rfl
        | some dst => exact (hno n dst hn hdst).elim

/-- The ranges a call's answer writes in the frame: the outgoing area, but in PE's pad region. -/
def callRanges (c : R.Code) (k : Nat) : List (Int × Nat) :=
  if c.inRegion k then [] else [(-(c.d.frameSize : Int), c.stackSize k)]

/-- The answer's bytes for `callRanges`. -/
def callNew (c : R.Code) (k : Nat) (a : R.Answer) : List (List AbstractByte) :=
  if c.inRegion k then [] else a.frame

/-- `answer` at a call: the outgoing area's bytes, then the result's parts or unwinding. -/
theorem answer_call_ok {c : R.Code} {s : R.RState} {a : R.Answer} {o : R.Out}
    {op : Reduced.Opcode} {dd : BitVec 32} {fo : Opnd Nat} {k : BitVec 64}
    {ws : List (BitVec 32)} {f : Full.Opcode}
    (hi : c.d.insns[s.pc]? = some (.native op [.slot dd, fo, .imm k, .words ws]))
    (hf : op.full = some f) (hsh : f.info.shape = .call) (h : R.answer c s a = .ok o) :
    ∃ st1, R.writeRanges (s.withWorld a.world).st (callRanges c s.pc) (callNew c s.pc a) =
        .ok st1 ∧
      ((∃ regs parts st2, a.result = .ret regs ∧ R.retRegs k.toNat false = .ok parts ∧
          parts.foldlM (init := st1) (fun st (q : Asm.RetPart × R.Reg) =>
            st.writeFrame (dd.toInt + q.1.off) ((regs.get q.2).take q.1.size)) = .ok st2 ∧
          o = .step ⟨s.pc + 1, s.fp, st2, s.args⟩) ∨
        (∃ exc, a.result = .unwind exc ∧
          R.unwindAt c { (s.withWorld a.world) with st := st1 } exc = .ok o)) := by
  unfold R.answer at h
  simp only [hi, hf, hsh, bind, Except.bind] at h
  have e1 : (s.withWorld a.world).pc = s.pc := rfl
  by_cases hreg : c.inRegion s.pc = true
  · simp only [e1, hreg, ↓reduceIte, pure, Except.pure] at h
    have hw : R.writeRanges (s.withWorld a.world).st (callRanges c s.pc) (callNew c s.pc a) =
        .ok (s.withWorld a.world).st := by
      simp only [callRanges, callNew, hreg, ↓reduceIte]
      rfl
    refine ⟨(s.withWorld a.world).st, hw, ?_⟩
    cases hr : a.result with
    | unwind exc =>
      rw [hr] at h
      exact .inr ⟨exc, rfl, h⟩
    | ret regs =>
      rw [hr] at h
      try dsimp only at h
      cases hp : R.retRegs k.toNat false with
      | error e => rw [hp] at h; cases h
      | ok parts =>
        rw [hp] at h
        try dsimp only at h
        split at h
        · cases h
        · rename_i st2 hst
          simp only [Except.ok.injEq] at h
          exact .inl ⟨regs, parts, st2, rfl, rfl, hst, h.symm⟩
  · have hreg' : c.inRegion s.pc = false := by simpa using hreg
    simp only [e1, hreg', Bool.false_eq_true, ↓reduceIte] at h
    cases hw : R.writeRanges (s.withWorld a.world).st [(-(c.d.frameSize : Int), c.stackSize s.pc)]
        a.frame with
    | error e => rw [hw] at h; cases h
    | ok st1 =>
      rw [hw] at h
      try dsimp only at h
      refine ⟨st1, by simp only [callRanges, callNew, hreg', Bool.false_eq_true, ↓reduceIte]; exact hw, ?_⟩
      cases hr : a.result with
      | unwind exc =>
        rw [hr] at h
        exact .inr ⟨exc, rfl, h⟩
      | ret regs =>
        rw [hr] at h
        try dsimp only at h
        cases hp : R.retRegs k.toNat false with
        | error e => rw [hp] at h; cases h
        | ok parts =>
          rw [hp] at h
          try dsimp only at h
          split at h
          · cases h
          · rename_i st2 hst
            simp only [pure, Except.pure, Except.ok.injEq] at h
            exact .inl ⟨regs, parts, st2, rfl, rfl, hst, h.symm⟩

/-- A call's answer from its parts. -/
theorem answer_call_of {c : R.Code} {s : R.RState} {a : R.Answer} {op : Reduced.Opcode}
    {dd : BitVec 32} {fo : Opnd Nat} {k : BitVec 64} {ws : List (BitVec 32)} {f : Full.Opcode}
    {st1 : OpSem.State}
    (hi : c.d.insns[s.pc]? = some (.native op [.slot dd, fo, .imm k, .words ws]))
    (hf : op.full = some f) (hsh : f.info.shape = .call)
    (hw : R.writeRanges (s.withWorld a.world).st (callRanges c s.pc) (callNew c s.pc a) =
      .ok st1) :
    (∀ regs parts st2, a.result = .ret regs → R.retRegs k.toNat false = .ok parts →
      parts.foldlM (init := st1) (fun st (q : Asm.RetPart × R.Reg) =>
        st.writeFrame (dd.toInt + q.1.off) ((regs.get q.2).take q.1.size)) = .ok st2 →
      R.answer c s a = .ok (.step ⟨s.pc + 1, s.fp, st2, s.args⟩)) ∧
    (∀ exc, a.result = .unwind exc →
      R.answer c s a = R.unwindAt c { (s.withWorld a.world) with st := st1 } exc) := by
  by_cases hreg : c.inRegion s.pc = true
  · have hst1 : st1 = (s.withWorld a.world).st := by
      simp only [callRanges, callNew, hreg, ↓reduceIte] at hw
      unfold R.writeRanges at hw
      simp only [List.isEmpty_nil, ↓reduceIte, pure, Except.pure, Except.ok.injEq] at hw
      exact hw.symm
    subst hst1
    refine ⟨fun regs parts st2 hres hp hst => ?_, fun exc hres => ?_⟩
    · unfold R.answer
      simp only [hi, hf, hsh, bind, Except.bind]
      have e1 : (s.withWorld a.world).pc = s.pc := rfl
      simp only [e1, hreg, ↓reduceIte, pure, Except.pure, hres, hp]
      rw [show (fun (st : OpSem.State) (x : Asm.RetPart × R.Reg) =>
          match x with | (p, r) => st.writeFrame (dd.toInt + ↑p.off) (List.take p.size (regs.get r))) =
          (fun st (q : Asm.RetPart × R.Reg) =>
            st.writeFrame (dd.toInt + q.1.off) ((regs.get q.2).take q.1.size)) from rfl, hst]
      all_goals rfl
    · unfold R.answer
      simp only [hi, hf, hsh, bind, Except.bind]
      have e1 : (s.withWorld a.world).pc = s.pc := rfl
      simp only [e1, hreg, ↓reduceIte, pure, Except.pure, hres]
      all_goals rfl
  · have hreg' : c.inRegion s.pc = false := by simpa using hreg
    have hw' : R.writeRanges (s.withWorld a.world).st [(-(c.d.frameSize : Int), c.stackSize s.pc)]
        a.frame = .ok st1 := by
      simpa only [callRanges, callNew, hreg', Bool.false_eq_true, ↓reduceIte] using hw
    refine ⟨fun regs parts st2 hres hp hst =>
      Ryo.Proofs.CallLemmas.answer_ret hi hf hsh hreg' hres hw' hp hst, fun exc hres => ?_⟩
    unfold R.answer
    simp only [hi, hf, hsh, bind, Except.bind]
    have e1 : (s.withWorld a.world).pc = s.pc := rfl
    simp only [e1, hreg', Bool.false_eq_true, ↓reduceIte, hw', hres]
    all_goals rfl

/-- Unwinding to a landing pad. -/
theorem unwindAt_step {c : R.Code} {u t : R.RState} {exc : ThinPointer}
    (h : R.unwindAt c u exc = .ok (.step t)) :
    ∃ pad b, c.cleanupAt u.pc = some (some pad, b) ∧
      t = { u with pc := pad, st := { u.st with exception := exc } } := by
  unfold R.unwindAt at h
  cases hcl : c.cleanupAt u.pc with
  | none => rw [hcl] at h; simp [OpSem.ub, throw, throwThe, MonadExceptOf.throw] at h
  | some cb =>
    obtain ⟨opad, b⟩ := cb
    cases opad with
    | none =>
      rw [hcl] at h
      simp only [pure, Except.pure, Except.ok.injEq] at h
      cases h
    | some pad =>
      rw [hcl] at h
      simp only [pure, Except.pure, Except.ok.injEq, R.Out.step.injEq] at h
      exact ⟨pad, b, rfl, h.symm⟩

theorem unwindAt_of {c : R.Code} {u : R.RState} {exc : ThinPointer} {pad : Nat} {b : Bool}
    (hcl : c.cleanupAt u.pc = some (some pad, b)) :
    R.unwindAt c u exc = .ok (.step { u with pc := pad, st := { u.st with exception := exc } }) := by
  unfold R.unwindAt
  simp only [hcl]
  all_goals rfl

/-! ### Calls: the shadow's reads (T3b) -/

/-- The callee from the shadow is the callee from the state, when a callee slot's bytes agree. -/
theorem callee_erase {P : Int → Prop} {st : OpSem.State} {f : Full.Opcode} {fo : Opnd Nat}
    {cal : R.Callee}
    (hrd : ∀ p, fo = .slot p → (f = .callPtr ∨ f = .tailCallPtr) →
      (eraseSt P st).readFrame p.toInt 8 = st.readFrame p.toInt 8)
    (h : R.callee (eraseSt P st) f fo = .ok cal) : R.callee st f fo = .ok cal := by
  cases fo with
  | slot p =>
    unfold R.callee at h ⊢
    by_cases hc : (f == .callPtr || f == .tailCallPtr) = true
    · have hc' : f = .callPtr ∨ f = .tailCallPtr := by simpa using hc
      simp only [hc, ↓reduceIte] at h ⊢
      rw [← hrd p rfl hc']
      exact h
    · simp only [hc, Bool.false_eq_true, ↓reduceIte] at h ⊢
      exact h
  | _ => exact h

theorem byteAt_erase_ok {P : Int → Prop} {st : OpSem.State} {o : Int} {b : AbstractByte}
    (h : (eraseSt P st).byteAt o = .ok b) : ∃ b', st.byteAt o = .ok b' := by
  cases he : st.escapedAt o with
  | none => exact ⟨st.frame o, by simp only [OpSem.State.byteAt, he]; all_goals rfl⟩
  | some e =>
    have he' : (eraseSt P st).escapedAt o = some e := he
    have heq : (eraseSt P st).byteAt o = st.byteAt o := by
      simp only [OpSem.State.byteAt, he, he']
      all_goals rfl
    exact ⟨b, by rw [← heq]; exact h⟩

theorem mapM_ok_of {α β : Type} {f g : α → OpSem.M β} :
    ∀ (l : List α) {r : List β}, l.mapM f = .ok r →
      (∀ x ∈ l, ∀ b, f x = .ok b → ∃ b', g x = .ok b') → ∃ r', l.mapM g = .ok r'
  | [], _, _, _ => ⟨[], rfl⟩
  | x :: l, r, h, hfg => by
    rw [List.mapM_cons] at h ⊢
    simp only [bind, Except.bind] at h ⊢
    cases hx : f x with
    | error e => rw [hx] at h; cases h
    | ok b =>
      rw [hx] at h
      obtain ⟨b', hb'⟩ := hfg x (List.mem_cons_self ..) b hx
      cases hl : l.mapM f with
      | error e => rw [hl] at h; cases h
      | ok r1 =>
        obtain ⟨r', hr'⟩ := mapM_ok_of l hl (fun y hy => hfg y (List.mem_cons_of_mem _ hy))
        rw [hb', hr']
        exact ⟨_, rfl⟩

/-- A read the shadow does succeeds from the state (only escaped bytes can fail, and they
agree). -/
theorem readFrame_ok_erase {P : Int → Prop} {st : OpSem.State} {off : Int} {n : Nat}
    {bs : List AbstractByte} (h : (eraseSt P st).readFrame off n = .ok bs) :
    ∃ bs', st.readFrame off n = .ok bs' := by
  unfold OpSem.State.readFrame at h ⊢
  exact mapM_ok_of _ h (fun i _ b hb => byteAt_erase_ok hb)

/-- The argument registers from the shadow are the state's when the by-value slots' bytes
agree (by-address arguments read no frame byte). -/
theorem argRegs_erase {P : Int → Prop} {st : OpSem.State} :
    ∀ (ws : List (BitVec 32)) {rs : R.Regs},
      (∀ x ∈ Frame.argPairs ws, ∀ m, x.2 = .read m →
        (eraseSt P st).readFrame x.1.toInt m = st.readFrame x.1.toInt m) →
      R.argRegs (eraseSt P st) ws = .ok rs → R.argRegs st ws = .ok rs
  | [], _, _, h => h
  | [_], _, _, h => h
  | s :: r :: rest, rs, hrd, h => by
    have hrest : ∀ x ∈ Frame.argPairs rest, ∀ m, x.2 = .read m →
        (eraseSt P st).readFrame x.1.toInt m = st.readFrame x.1.toInt m :=
      fun x hx m hm => hrd x (by simp only [Frame.argPairs]; exact List.mem_cons_of_mem _ hx) m hm
    unfold R.argRegs at h ⊢
    simp only [bind, Except.bind] at h ⊢
    cases hr : R.argRegs (eraseSt P st) rest with
    | error e => rw [hr] at h; cases h
    | ok rs1 =>
      rw [hr] at h
      rw [argRegs_erase rest hrest hr]
      by_cases hb : (r.toNat &&& Asm.argAddr != 0) = true
      · simp only [hb, ↓reduceIte] at h ⊢
        exact h
      · simp only [hb, Bool.false_eq_true, ↓reduceIte] at h ⊢
        cases ha : Asm.ArgReg.of? r.toNat false with
        | none =>
          simp only [ha] at h ⊢
          exact h
        | some a =>
          simp only [ha] at h ⊢
          rw [← hrd (s, .read a.size) (by simp [Frame.argPairs, hb, ha]) a.size rfl]
          exact h

theorem bit_in_range {o : Int} (hif : InFrame S o) {off : BitVec 32} {n : Nat}
    (h1 : off.toInt ≤ o) (h2 : o < off.toInt + n) :
    (Frame.range S.c.d.frameSize off n).1 ≤ bit S o ∧
      bit S o < (Frame.range S.c.d.frameSize off n).2 := by
  obtain ⟨hf1, hf2⟩ := hif
  simp only [Frame.range, bit]
  omega

theorem in_range_of_bit {o : Int} (hif : InFrame S o) {off : BitVec 32} {n : Nat}
    (h1 : (Frame.range S.c.d.frameSize off n).1 ≤ bit S o)
    (h2 : bit S o < (Frame.range S.c.d.frameSize off n).2) :
    off.toInt ≤ o ∧ o < off.toInt + n := by
  obtain ⟨hf1, hf2⟩ := hif
  simp only [Frame.range, bit] at h1 h2
  omega

/-- A read of `[off, off + n)` among an instruction's operand reads agrees between the shadow
and R after the scopes. -/
theorem call_read_agree (C : Cert S) {s s1 : R.RState} {P : Int → Prop} (h : StepPre S C s P)
    (hs1 : (S.c.scopesAt s.pc).foldlM R.applyScope s = .ok s1)
    (hends : C.fl.ends[s.pc]! = (Frame.scopesAt S.c.d)[s.pc]!.filterMap fun (_, sc) =>
      if sc.kind == .end then some (Frame.range S.c.d.frameSize sc.frameOffset sc.size) else none)
    {L : Frame.Ranges} (hsub : ∀ r ∈ L, r ∈ C.fl.operand[s.pc]!) {off : BitVec 32} {n : Nat}
    (hcov : ∀ i, (Frame.range S.c.d.frameSize off n).1 ≤ i →
      i < (Frame.range S.c.d.frameSize off n).2 → (Frame.Ranges.bits L).testBit i = true) :
    (eraseSt P s1.st).readFrame off.toInt n = s1.st.readFrame off.toInt n := by
  apply readFrame_erase_of
  intro o h1 h2 hpo _
  obtain ⟨hif, -, -, -⟩ := h.patch o hpo
  obtain ⟨b1, b2⟩ := bit_in_range hif h1 h2
  exact read_uninit C h hs1 hends hpo (gen_of_operand_mem hsub (hcov _ b1 b2))

/-! ### Calls: the row (T3b) -/

theorem retParts_lt {k : Nat} {ab : Option Asm.RetPart × Option Asm.RetPart}
    (h : Asm.retParts k false = some ab) : k < 2 ^ 32 := by
  rw [Ryo.Proofs.CallLemmas.retPartsS_eq] at h
  by_cases h24 : (k >>> 24 != 0) = true
  · simp [h24] at h
  · have h0 : k >>> 24 = 0 := by simpa using h24
    rw [Nat.shiftRight_eq_div_pow] at h0
    have e24 : (2 : Nat) ^ 24 = 16777216 := rfl
    have e32 : (2 : Nat) ^ 32 = 4294967296 := rfl
    rw [e24] at h0
    rw [e32]
    omega

theorem foldl_append_mem {β γ σ : Type} (F : (List (β × γ) × σ) → β → (List (β × γ) × σ))
    (hF : ∀ st p, ∃ r x, F st p = (st.1 ++ [(p, r)], x)) :
    ∀ (ps : List β) (st : List (β × γ) × σ),
      (∀ y ∈ st.1, y ∈ (ps.foldl F st).1) ∧ ∀ p ∈ ps, ∃ r, (p, r) ∈ (ps.foldl F st).1
  | [], st => ⟨fun y hy => hy, fun p hp => by cases hp⟩
  | p :: ps, st => by
    obtain ⟨r, x, hp⟩ := hF st p
    obtain ⟨ih1, ih2⟩ := foldl_append_mem F hF ps (F st p)
    simp only [List.foldl_cons]
    refine ⟨fun y hy => ih1 y (by rw [hp]; exact List.mem_append_left _ hy), fun q hq => ?_⟩
    rcases List.mem_cons.1 hq with hqp | hq
    · subst hqp
      exact ⟨r, ih1 _ (by rw [hp]; exact List.mem_append_right _ (List.mem_singleton_self _))⟩
    · exact ih2 q hq

/-- Every part of `retParts` has its register in `retRegs`' list. -/
theorem retRegs_cover {k : Nat} {parts : List (Asm.RetPart × R.Reg)}
    (h : R.retRegs k false = .ok parts) :
    ∃ a b, Asm.retParts k false = some (a, b) ∧
      ∀ q ∈ [a, b].filterMap id, ∃ r, (q, r) ∈ parts := by
  unfold R.retRegs at h
  cases hk : Asm.retParts k false with
  | none => simp [hk, OpSem.illFormed, throw, throwThe, MonadExceptOf.throw] at h
  | some ab =>
    obtain ⟨a, b⟩ := ab
    simp only [hk, pure, Except.pure, Except.ok.injEq] at h
    subst h
    refine ⟨a, b, rfl, (foldl_append_mem _ (fun st p => ?_) _ _).2⟩
    obtain ⟨acc, g, x⟩ := st
    by_cases hx : p.xmm = true
    · exact ⟨.xmm x, (g, x + 1), by simp [hx]⟩
    · exact ⟨.gpr g, (g + 1, x), by simp [hx]⟩

theorem part_le_width {q : Asm.RetPart} {r : R.Reg} (hp : Ryo.Proofs.CallLemmas.partOkS q)
    (hr : Ryo.Proofs.ArgRet.RegFor q r) : q.size ≤ r.width := by
  unfold Ryo.Proofs.CallLemmas.partOkS at hp
  rcases hr with ⟨hx, hr | hr⟩ | ⟨hx, hr | hr⟩ <;> subst hr <;> simp [hx] at hp <;>
    simp only [R.Reg.width] <;> omega

set_option maxRecDepth 100000 in
theorem reduced_callOpsTable : (List.range Reduced.toFullTable.size).all (fun i =>
    match Reduced.toFullTable[i]! with
    | some f => f.info.shape != .call ||
        (decide (f ≠ Full.Opcode.tailCallPtr) &&
          ((Reduced.Opcode.info ⟨i.toUInt16⟩).operands.map (·.name)) ==
            ["d", if f = Full.Opcode.callPtr then "p"
              else if f = Full.Opcode.call then "f" else "sym", "k", "a"])
    | none => true) = true := by
  decide +kernel

/-- A reduced opcode of `call` shape: not `tail_call.ptr`, and the operands `d`, its callee
(`p` exactly for `call.ptr`), `k`, `a`. -/
theorem reduced_call_ops {op : Reduced.Opcode} {f : Full.Opcode} (h : op.full = some f)
    (hs : f.info.shape = .call) : f ≠ .tailCallPtr ∧ op.info.operands.map (·.name) =
      ["d", if f = .callPtr then "p" else if f = .call then "f" else "sym", "k", "a"] := by
  unfold Reduced.Opcode.full at h
  have hlt : op.val.toNat < Reduced.toFullTable.size := Classical.byContradiction fun hn => by
    rw [getElem!_neg Reduced.toFullTable op.val.toNat hn] at h
    cases h
  have := List.all_eq_true.1 reduced_callOpsTable op.val.toNat (List.mem_range.2 hlt)
  rw [h] at this
  simp only [hs, bne_self_eq_false, Bool.false_or, Bool.and_eq_true, decide_eq_true_eq,
    beq_iff_eq] at this
  have hop : (⟨op.val.toNat.toUInt16⟩ : Reduced.Opcode) = op := by cases op; simp
  rw [hop] at this
  exact this

/-- A call's frame operands: reads (the callee slot of `call.ptr`), the result's part writes at
`d`, and the argument list's. -/
theorem native_call_opnds {op : Reduced.Opcode} {f : Full.Opcode} (hf : op.full = some f)
    (hs : f.info.shape = .call) (dd : BitVec 32) (fo : Opnd Nat) (k : BitVec 64)
    (ws : List (BitVec 32)) (pe : Bool) (lends : List (BitVec 32 × Nat)) (tmpl : Option String)
    {a b : Option Asm.RetPart} (hk : k.toNat < 2 ^ 32)
    (hrp : Asm.retParts k.toNat false = some (a, b)) :
    ∃ A, (Frame.native op [.slot dd, fo, .imm k, .words ws] pe lends tmpl).opnds =
        A ++ (if k.toNat = 0 then [] else
          ([a, b].filterMap id).map fun q =>
            (dd + BitVec.ofNat 32 q.off, Frame.Access.write q.size)) ++
        Frame.argPairs ws ∧
      (∀ x ∈ A, ∃ m, x.2 = .read m) ∧
      ((f = .callPtr ∨ f = .tailCallPtr) → ∀ p, fo = .slot p → (p, Frame.Access.read 8) ∈ A) := by
  obtain ⟨hntp, hn⟩ := reduced_call_ops hf hs
  have hshr : op.info.shape = .call := (reduced_shape hf).trans hs
  obtain ⟨o1, o2, o3, o4, hops, h1, h2, h3, h4⟩ : ∃ o1 o2 o3 o4,
      op.info.operands = [o1, o2, o3, o4] ∧ o1.name = "d" ∧
      o2.name = (if f = .callPtr then "p" else if f = .call then "f" else "sym") ∧
      o3.name = "k" ∧ o4.name = "a" := by
    cases hq : op.info.operands with
    | nil => rw [hq] at hn; cases hn
    | cons o1 t1 =>
      cases t1 with
      | nil => rw [hq] at hn; simp at hn
      | cons o2 t2 =>
        cases t2 with
        | nil => rw [hq] at hn; simp at hn
        | cons o3 t3 =>
          cases t3 with
          | nil => rw [hq] at hn; simp at hn
          | cons o4 t4 =>
            cases t4 with
            | cons _ _ => rw [hq] at hn; simp at hn
            | nil =>
              rw [hq] at hn
              simp only [List.map_cons, List.map_nil, List.cons.injEq, and_true] at hn
              exact ⟨o1, o2, o3, o4, rfl, hn.1, hn.2.1, hn.2.2.1, hn.2.2.2⟩
  have hkm1 : k.toNat % 2 ^ 32 = k.toNat := Nat.mod_eq_of_lt hk
  have hkm2 : k.toNat % 4294967296 = k.toNat := Nat.mod_eq_of_lt (by omega)
  by_cases hp : f = .callPtr
  · rw [if_pos hp] at h2
    cases fo with
    | slot p =>
      refine ⟨[(p, .read 8)], ?_, by simp, fun _ q hq => by cases hq; simp⟩
      unfold Frame.native
      by_cases hk0 : k.toNat = 0 <;>
        simp [hshr, hops, h1, h2, h3, h4, hkm1, hkm2, hk0, hrp, Function.comp_def]
    | _ =>
      refine ⟨[], ?_, by simp, fun _ q hq => by cases hq⟩
      unfold Frame.native
      by_cases hk0 : k.toNat = 0 <;>
        simp [hshr, hops, h1, h2, h3, h4, hkm1, hkm2, hk0, hrp, Function.comp_def]
  · rw [if_neg hp] at h2
    refine ⟨[], ?_, by simp, fun hq => ?_⟩
    · unfold Frame.native
      by_cases hc : f = .call
      · rw [if_pos hc] at h2
        by_cases hk0 : k.toNat = 0 <;>
          simp [hshr, hops, h1, h2, h3, h4, hkm1, hkm2, hk0, hrp, Function.comp_def]
      · rw [if_neg hc] at h2
        by_cases hk0 : k.toNat = 0 <;>
          simp [hshr, hops, h1, h2, h3, h4, hkm1, hkm2, hk0, hrp, Function.comp_def]
    · rcases hq with hq | hq
      · exact (hp hq).elim
      · exact (hntp hq).elim

set_option maxRecDepth 100000 in
theorem reduced_retOpsTable : (List.range Reduced.toFullTable.size).all (fun i =>
    match Reduced.toFullTable[i]! with
    | some f => f.info.shape != .ret ||
        ((Reduced.Opcode.info ⟨i.toUInt16⟩).operands.map (·.name)) == ["s", "k"]
    | none => true) = true := by
  decide +kernel

/-- A reduced opcode of `ret` shape has the operands `s`, `k`. -/
theorem reduced_ret_ops {op : Reduced.Opcode} {f : Full.Opcode} (h : op.full = some f)
    (hs : f.info.shape = .ret) : op.info.operands.map (·.name) = ["s", "k"] := by
  unfold Reduced.Opcode.full at h
  have hlt : op.val.toNat < Reduced.toFullTable.size := Classical.byContradiction fun hn => by
    rw [getElem!_neg Reduced.toFullTable op.val.toNat hn] at h
    cases h
  have := List.all_eq_true.1 reduced_retOpsTable op.val.toNat (List.mem_range.2 hlt)
  rw [h] at this
  simp only [hs, bne_self_eq_false, Bool.false_or, beq_iff_eq] at this
  have hop : (⟨op.val.toNat.toUInt16⟩ : Reduced.Opcode) = op := by cases op; simp
  rw [hop] at this
  exact this

set_option maxRecDepth 100000 in
theorem reduced_tailOpsTable : (List.range Reduced.toFullTable.size).all (fun i =>
    match Reduced.toFullTable[i]! with
    | some f => f.info.shape != .tailCall ||
        (decide (f ≠ Full.Opcode.callPtr) &&
          ((Reduced.Opcode.info ⟨i.toUInt16⟩).operands.map (·.name)) ==
            [if f = Full.Opcode.tailCallPtr then "p" else "f", "a"])
    | none => true) = true := by
  decide +kernel

/-- A reduced opcode of `tail_call` shape: not `call.ptr`, and the operands its callee (`p`
exactly for `tail_call.ptr`), `a`. -/
theorem reduced_tail_ops {op : Reduced.Opcode} {f : Full.Opcode} (h : op.full = some f)
    (hs : f.info.shape = .tailCall) : f ≠ .callPtr ∧ op.info.operands.map (·.name) =
      [if f = .tailCallPtr then "p" else "f", "a"] := by
  unfold Reduced.Opcode.full at h
  have hlt : op.val.toNat < Reduced.toFullTable.size := Classical.byContradiction fun hn => by
    rw [getElem!_neg Reduced.toFullTable op.val.toNat hn] at h
    cases h
  have := List.all_eq_true.1 reduced_tailOpsTable op.val.toNat (List.mem_range.2 hlt)
  rw [h] at this
  simp only [hs, bne_self_eq_false, Bool.false_or, Bool.and_eq_true, decide_eq_true_eq,
    beq_iff_eq] at this
  have hop : (⟨op.val.toNat.toUInt16⟩ : Reduced.Opcode) = op := by cases op; simp
  rw [hop] at this
  exact this

/-- `ret s, k`'s frame operands: a read of the parts' extent at `s` (none for `k = 0`). -/
theorem native_ret_opnds {op : Reduced.Opcode} {f : Full.Opcode} (hf : op.full = some f)
    (hs : f.info.shape = .ret) (src : BitVec 32) (k : BitVec 64) (pe : Bool)
    (lends : List (BitVec 32 × Nat)) (tmpl : Option String)
    {a b : Option Asm.RetPart} (hk : k.toNat < 2 ^ 32)
    (hrp : Asm.retParts k.toNat true = some (a, b)) :
    (Frame.native op [.slot src, .imm k] pe lends tmpl).opnds =
      if k.toNat = 0 then [] else
        [(src, Frame.Access.read
          (([a, b].filterMap id).foldl (fun x p => max x (p.off + p.size)) 0))] := by
  have hn := reduced_ret_ops hf hs
  have hshr : op.info.shape = .ret := (reduced_shape hf).trans hs
  obtain ⟨o1, o2, hops, h1, h2⟩ : ∃ o1 o2, op.info.operands = [o1, o2] ∧ o1.name = "s" ∧
      o2.name = "k" := by
    cases hq : op.info.operands with
    | nil => rw [hq] at hn; cases hn
    | cons o1 t =>
      cases t with
      | nil => rw [hq] at hn; simp at hn
      | cons o2 t =>
        cases t with
        | nil =>
          rw [hq] at hn
          simp only [List.map_cons, List.map_nil, List.cons.injEq, and_true] at hn
          exact ⟨o1, o2, rfl, hn.1, hn.2⟩
        | cons _ _ => rw [hq] at hn; simp at hn
  have hkm1 : k.toNat % 2 ^ 32 = k.toNat := Nat.mod_eq_of_lt hk
  have hkm2 : k.toNat % 4294967296 = k.toNat := Nat.mod_eq_of_lt (by omega)
  unfold Frame.native
  by_cases hk0 : k.toNat = 0 <;> simp [hshr, hops, h1, h2, hkm1, hkm2, hk0, hrp]

/-- A tail call's frame operands: reads (the callee slot of `tail_call.ptr`), then the argument
list's. -/
theorem native_tail_opnds {op : Reduced.Opcode} {f : Full.Opcode} (hf : op.full = some f)
    (hs : f.info.shape = .tailCall) (fo : Opnd Nat) (ws : List (BitVec 32)) (pe : Bool)
    (lends : List (BitVec 32 × Nat)) (tmpl : Option String) :
    ∃ A, (Frame.native op [fo, .words ws] pe lends tmpl).opnds = A ++ Frame.argPairs ws ∧
      (∀ x ∈ A, ∃ m, x.2 = .read m) ∧
      ((f = .callPtr ∨ f = .tailCallPtr) → ∀ p, fo = .slot p → (p, Frame.Access.read 8) ∈ A) := by
  obtain ⟨hncp, hn⟩ := reduced_tail_ops hf hs
  have hshr : op.info.shape = .tailCall := (reduced_shape hf).trans hs
  obtain ⟨o1, o2, hops, h1, h2⟩ : ∃ o1 o2, op.info.operands = [o1, o2] ∧
      o1.name = (if f = .tailCallPtr then "p" else "f") ∧ o2.name = "a" := by
    cases hq : op.info.operands with
    | nil => rw [hq] at hn; cases hn
    | cons o1 t =>
      cases t with
      | nil => rw [hq] at hn; simp at hn
      | cons o2 t =>
        cases t with
        | nil =>
          rw [hq] at hn
          simp only [List.map_cons, List.map_nil, List.cons.injEq, and_true] at hn
          exact ⟨o1, o2, rfl, hn.1, hn.2⟩
        | cons _ _ => rw [hq] at hn; simp at hn
  by_cases hp : f = .tailCallPtr
  · rw [if_pos hp] at h1
    cases fo with
    | slot p =>
      refine ⟨[(p, .read 8)], ?_, by simp, fun _ q hq => by cases hq; simp⟩
      unfold Frame.native
      simp [hshr, hops, h1, h2]
    | _ =>
      refine ⟨[], ?_, by simp, fun _ q hq => by cases hq⟩
      unfold Frame.native
      simp [hshr, hops, h1, h2]
  · rw [if_neg hp] at h1
    refine ⟨[], ?_, by simp, fun hq => ?_⟩
    · unfold Frame.native
      simp [hshr, hops, h1, h2]
    · rcases hq with hq | hq
      · exact (hncp hq).elim
      · exact (hp hq).elim

/-- An argument list writes no frame byte. -/
theorem argPairs_no_write : ∀ (ws : List (BitVec 32)) {x : BitVec 32} {m : Nat},
    (x, Frame.Access.write m) ∈ Frame.argPairs ws → False
  | [], _, _, h => by simp [Frame.argPairs] at h
  | [_], _, _, h => by simp [Frame.argPairs] at h
  | s :: r :: rest, x, m, h => by
    simp only [Frame.argPairs, List.mem_cons] at h
    rcases h with h | h
    · simp only [Prod.mk.injEq] at h
      obtain ⟨-, h⟩ := h
      split at h <;> cases h
    · exact argPairs_no_write rest h

/-- At a non-inline call: its row from `Frame.native` (`isCall`), the sret destination
`Uninit`, and its `ends`. -/
theorem flowOf_call_row {d : Decoded} {mode : Ryo.Obj.Mode} {facts : Frame.Facts}
    {fl : Frame.Flow} (h : Frame.Flow.of d mode facts = .ok fl) {k : Nat} {op : Reduced.Opcode}
    {ops : List (Opnd Nat)} (hi : d.insns[k]? = some (.native op ops))
    (hni : (op.full.bind Asm.classOf).isSome = false) (hc : op.info.shape = .call) :
    ∃ eb, fl.kill[k]! = (Frame.Flow.opndRanges d.frameSize true eb
        (Frame.native op ops mode.pe (Frame.Flow.lendsOf (Frame.scopesAt d) k)
          (facts.islandTemplate k)).opnds).2 ∧
      (∀ i, fl.uninit[k]!.bits.testBit i = true → ∃ m sd, facts.sretSize k = some m ∧
        Frame.sretDest (Frame.callArgs ops) = some sd ∧
        (Frame.range d.frameSize sd m).1 ≤ i ∧ i < (Frame.range d.frameSize sd m).2) ∧
      (∀ r ∈ (Frame.Flow.opndRanges d.frameSize true eb
        (Frame.native op ops mode.pe (Frame.Flow.lendsOf (Frame.scopesAt d) k)
          (facts.islandTemplate k)).opnds).1, r ∈ fl.operand[k]!) ∧
      fl.ends[k]! = (Frame.scopesAt d)[k]!.filterMap fun (_, sc) =>
        if sc.kind == .end then some (Frame.range d.frameSize sc.frameOffset sc.size) else none := by
  have hk : k < d.insns.size := by
    rcases Nat.lt_or_ge k d.insns.size with h | h
    · exact h
    · rw [Array.getElem?_eq_none h] at hi; cases hi
  have hik : d.insns[k]! = .native op ops := by
    rw [getElem!_pos d.insns k hk]
    rw [Array.getElem?_eq_getElem hk] at hi
    exact Option.some.inj hi
  have hc1 : (op.info.shape == .call) = true := by rw [hc]; rfl
  obtain ⟨e, he, eb, hkl, hun, hen, hop⟩ := flowOf_row4 h hk
  rw [hik] at he
  simp only [Frame.effects, hni, Bool.false_eq_true, ↓reduceIte, pure, Except.pure,
    Except.ok.injEq] at he
  subst he
  refine ⟨eb, ?_, fun i hb => ?_, fun r hr => ?_, ?_⟩
  · rw [hkl]
    simp only [Frame.Flow.rowOf, Frame.Flow.callInfo, hik, hc1, Bool.true_or]
  · rw [hun] at hb
    simp only [Frame.Flow.rowOf, Frame.Flow.callInfo, hik, hc1] at hb
    cases hs1 : facts.sretSize k with
    | none =>
      cases hs2 : Frame.sretDest (Frame.callArgs ops) <;>
        simp [hs1, hs2, Frame.Ranges.bits] at hb
    | some m =>
      cases hs2 : Frame.sretDest (Frame.callArgs ops) with
      | none => simp [hs1, hs2, Frame.Ranges.bits] at hb
      | some sd =>
        simp only [hs1, hs2] at hb
        rw [testBit_rangesBits] at hb
        simp only [List.any_cons, List.any_nil, Bool.or_false, Bool.and_eq_true,
          decide_eq_true_eq] at hb
        exact ⟨m, sd, rfl, rfl, hb.1, hb.2⟩
  · rw [hop]
    simp only [Frame.Flow.rowOf, Frame.Flow.callInfo, hik, hc1, Bool.true_or]
    exact List.mem_append_left _ hr
  · rw [hen]
    all_goals rfl

theorem flow_succ_next_call {d : Decoded} {k : Nat} {op : Reduced.Opcode}
    {ops : List (Opnd Nat)} (hi : d.insns[k]? = some (.native op ops))
    (hs : op.info.shape = .call) (hn : k + 1 < d.insns.size) : k + 1 ∈ (Frame.flow d).1[k]! := by
  have hk : k < d.insns.size := by omega
  unfold Frame.flow
  simp only [Id.run_bind, Id.run_pure, Std.Legacy.Range.forIn'_eq_forIn'_range',
    Std.Legacy.Range.size]
  refine forIn'_push_mem (R := fun a x => ∀ op ops, d.insns[a]? = some (.native op ops) →
    op.info.shape = .call → a + 1 < d.insns.size → a + 1 ∈ x) _ ?_ (by simpa using hk)
    (fun x hR => hR op ops hi hs hn)
  intro a h b
  refine ⟨_, rfl, ?_⟩
  intro op' ops' hop hs' hn'
  have hd : ∀ hh : a < d.insns.size, d.insns[a]'hh = .native op' ops' := fun hh => by
    rw [Array.getElem?_eq_getElem hh] at hop
    exact Option.some.inj hop
  simp only [hd]
  simp [hs', hn']

/-! ### Calls: frame writes on two states (T3b) -/

theorem fold_rel_gen {α : Type} {f1 f2 : Int → AbstractByte}
    {F : OpSem.State → α → OpSem.M OpSem.State}
    (hF : ∀ a b x, OpSem.FrameRel f1 f2 a b →
      OpSem.ResultRel (OpSem.FrameRel f1 f2) (F a x) (F b x)) :
    ∀ (L : List α) (a b : OpSem.State), OpSem.FrameRel f1 f2 a b →
      OpSem.ResultRel (OpSem.FrameRel f1 f2) (L.foldlM F a) (L.foldlM F b)
  | [], a, b, h => h
  | p :: L, a, b, h => by
    simp only [List.foldlM_cons, bind, Except.bind]
    have h1 := hF a b p h
    revert h1
    cases F a p <;> cases F b p <;> simp only [OpSem.ResultRel, imp_self, false_implies]
    all_goals (intro hh; first | exact fold_rel_gen hF L _ _ hh | (subst hh; rfl))

theorem fold_pair_gen {α : Type} {F : OpSem.State → α → OpSem.M OpSem.State}
    (offOf : α → Int) (bsOf : α → List AbstractByte)
    (hF : ∀ st x st', F st x = .ok st' → st.writeFrame (offOf x) (bsOf x) = .ok st') :
    ∀ (L : List α) (a b a' b' : OpSem.State),
      a.escaped = b.escaped → L.foldlM F a = .ok a' → L.foldlM F b = .ok b' →
      a'.escaped = a.escaped ∧ ∀ o,
        ((∃ x ∈ L, a.privateIn (offOf x) (bsOf x).length o = true) → a'.frame o = b'.frame o) ∧
        ((∀ x ∈ L, a.privateIn (offOf x) (bsOf x).length o = false) →
          a'.frame o = a.frame o ∧ b'.frame o = b.frame o)
  | [], a, b, a', b', _, ha, hb => by
    cases ha; cases hb
    refine ⟨rfl, fun o => ⟨?_, fun _ => ⟨rfl, rfl⟩⟩⟩
    rintro ⟨_, hp, _⟩
    cases hp
  | p :: L, a, b, a', b', he, ha, hb => by
    simp only [List.foldlM_cons, bind, Except.bind] at ha hb
    cases ha1 : F a p with
    | error e => rw [ha1] at ha; cases ha
    | ok a1 =>
      cases hb1 : F b p with
      | error e => rw [hb1] at hb; cases hb
      | ok b1 =>
        rw [ha1] at ha
        rw [hb1] at hb
        obtain ⟨hea1, heb1, hw⟩ := writeFrame_pair he (hF _ _ _ ha1) (hF _ _ _ hb1)
        have he1 : a1.escaped = b1.escaped := by rw [hea1, heb1, he]
        obtain ⟨he', ih⟩ := fold_pair_gen offOf bsOf hF L a1 b1 a' b' he1 ha hb
        have hpi : ∀ q : α, ∀ o,
            a1.privateIn (offOf q) (bsOf q).length o = a.privateIn (offOf q) (bsOf q).length o :=
          fun q o => privateIn_congr hea1 _ _ o
        refine ⟨he'.trans hea1, fun o => ⟨fun ⟨q, hq, hqo⟩ => ?_, fun hno => ?_⟩⟩
        · by_cases hL : ∃ q ∈ L, a1.privateIn (offOf q) (bsOf q).length o = true
          · exact (ih o).1 hL
          · have hL' : ∀ q ∈ L, a1.privateIn (offOf q) (bsOf q).length o = false := by
              intro q hq
              cases hb' : a1.privateIn (offOf q) (bsOf q).length o
              · rfl
              · exact (hL ⟨q, hq, hb'⟩).elim
            obtain ⟨h1, h2⟩ := (ih o).2 hL'
            rw [h1, h2]
            rcases List.mem_cons.1 hq with rfl | hq
            · exact (hw o).1 hqo
            · rw [← hpi q o] at hqo
              exact (hL ⟨q, hq, hqo⟩).elim
        · have hL' : ∀ q ∈ L, a1.privateIn (offOf q) (bsOf q).length o = false := fun q hq => by
            rw [hpi q o]; exact hno q (List.mem_cons_of_mem _ hq)
          obtain ⟨h1, h2⟩ := (ih o).2 hL'
          obtain ⟨h3, h4⟩ := (hw o).2 (hno p (List.mem_cons_self ..))
          exact ⟨h1.trans h3, h2.trans h4⟩

/-! ### Calls: the step (T3b) -/

/-- T3b: a call, its fall-through in range (`callNext`) and its pad (`padRange`). -/
theorem rnext_erase_call' (C : Cert S) {s t' : R.RState} {P : Int → Prop} (h : StepPre S C s P)
    {op : Reduced.Opcode} {f : Full.Opcode} {dd : BitVec 32} {fo : Opnd Nat} {k : BitVec 64}
    {ws : List (BitVec 32)}
    (hi : S.c.d.insns[s.pc]? = some (.native op [.slot dd, fo, .imm k, .words ws]))
    (hf : op.full = some f) (hsc : f.info.shape = .call)
    (hans : ∀ ch q s1 a, R.step S.c (erase s P) ch = .ok (.ext q s1) →
      R.answer S.c s1 a = .ok (.step t') → AnswerOk S s a)
    (hnx : s.pc + 1 ≤ S.c.d.insns.size) (hn : RNext S.c (erase s P) t') : StepOut S C s P t' := by
  have hi' : S.c.d.insns[(erase s P).pc]? = some (.native op [.slot dd, fo, .imm k, .words ws]) :=
    hi
  -- only an answer
  obtain ⟨ch, q, t1, a, hstep, ha⟩ : ∃ ch q t1 a, R.step S.c (erase s P) ch = .ok (.ext q t1) ∧
      R.answer S.c t1 a = .ok (.step t') := by
    cases hn with
    | step hs =>
      obtain ⟨_, _, _, _, _, _, _, _, _, _, _, _, _, _, hc⟩ := step_call_ok hi' hf hsc hs
      cases hc
    | answer hs ha => exact ⟨_, _, _, _, hs, ha⟩
  have hok := hans ch q t1 a hstep ha
  obtain ⟨u1, parts, cal, regs, sp, stack, stS, hscS, hp, hcal, hargs, hR1, hR2, hsret, hq⟩ :=
    step_call_ok hi' hf hsc hstep
  cases hq
  obtain ⟨s1, hs1, rfl⟩ := scopes_erase_eq C h hscS
  have hpc : s1.pc = s.pc := (Ryo.Proofs.Scope.scopes_keeps _ hs1).pc
  have hlt := h.lt
  have hiS : S.c.d.insns[s1.pc]? = some (.native op [.slot dd, fo, .imm k, .words ws]) := by
    rw [hpc]; exact hi
  -- the row
  have hshr : op.info.shape = .call := (reduced_shape hf).trans hsc
  have hni : (op.full.bind Asm.classOf).isSome = false := by
    cases hb : (op.full.bind Asm.classOf).isSome
    · rfl
    · exact (h.notInline ⟨op, _, hi, hb⟩).elim
  obtain ⟨eb, hkill, hunin, hsub, hends⟩ := flowOf_call_row C.hfl hi hni hshr
  obtain ⟨pa, pb, hrp, hcover⟩ := retRegs_cover hp
  have hk32 : k.toNat < 2 ^ 32 := retParts_lt hrp
  obtain ⟨A, hops, hAread, hAp⟩ := native_call_opnds hf hsc dd fo k ws S.c.mode.pe
    (Frame.Flow.lendsOf (Frame.scopesAt S.c.d) s.pc) (C.facts.islandTemplate s.pc) hk32 hrp
  have hsucc : C.fl.succ = (Frame.flow S.c.d).1 := flowOf_succ C.hfl
  have hssz : C.fl.succ.size = S.c.d.insns.size := by rw [hsucc, flow_succ_size]
  have hpsz : C.fl.pad.size = C.fl.succ.size := (postFix_spec C.hlive).2.1
  have hkk : s.pc < C.fl.succ.size := by rw [hssz]; exact hlt
  have hedges := flow_edges_get hkk (by rw [hpsz]; exact hkk)
  -- the operand reads agree
  have hcov : ∀ (x : BitVec 32 × Frame.Access) (m : Nat),
      x ∈ (Frame.native op [.slot dd, fo, .imm k, .words ws] S.c.mode.pe
        (Frame.Flow.lendsOf (Frame.scopesAt S.c.d) s.pc) (C.facts.islandTemplate s.pc)).opnds →
      x.2 = .read m → (eraseSt P s1.st).readFrame x.1.toInt m = s1.st.readFrame x.1.toInt m := by
    intro x m hx hm
    refine call_read_agree C h hs1 hends hsub (fun i h1 h2 => ?_)
    have hiF : i < S.c.d.frameSize := by simp only [Frame.range] at h2; omega
    exact opndRanges_read_cover _ _ _ hiF _ ([], []) (.inr ⟨x, hx, m, hm, h1, h2⟩)
  have hcalR : R.callee s1.st f fo = .ok cal := by
    refine callee_erase (fun p hfo hcp => ?_) hcal
    refine hcov (p, .read 8) 8 ?_ rfl
    rw [hops]
    exact List.mem_append_left _ (List.mem_append_left _ (hAp hcp p hfo))
  have hargsR : R.argRegs s1.st ws = .ok regs := by
    refine argRegs_erase ws (fun x hx m hm => hcov x m ?_ hm) hargs
    rw [hops]
    exact List.mem_append_right _ hx
  -- the outgoing area and the sret write from `s1`
  obtain ⟨stackR, hR1', hR2'⟩ : ∃ stackR,
      (S.c.inRegion s1.pc = true → sp = ch.sp ∧
        stackR = List.replicate (S.c.stackSize s1.pc) AbstractByte.uninit) ∧
      (S.c.inRegion s1.pc = false → R.frameAddr s1.fp (-(S.c.d.frameSize : Int)) = .ok sp ∧
        s1.st.readFrame (-(S.c.d.frameSize : Int)) (S.c.stackSize s1.pc) = .ok stackR) := by
    cases hr : S.c.inRegion s1.pc with
    | true => exact ⟨_, fun _ => ⟨(hR1 hr).1, rfl⟩, (fun h' => by cases h')⟩
    | false =>
      obtain ⟨hfa, hrd⟩ := hR2 hr
      obtain ⟨st', hst'⟩ := readFrame_ok_erase hrd
      exact ⟨st', (fun h' => by cases h'), fun _ => ⟨hfa, hst'⟩⟩
  unfold SretW at hsret
  obtain ⟨st2, hsretR, rfl⟩ : ∃ st2, SretW S.c s1.pc ws s1.st st2 ∧ stS = eraseSt P st2 := by
    rcases hsret with ⟨n, dst, hn, hdst, hw⟩ | ⟨hno, heq⟩
    · obtain ⟨st2, hw2, rfl⟩ := writeFrame_erase hw
      exact ⟨st2, Or.inl ⟨n, dst, hn, hdst, hw2⟩, rfl⟩
    · exact ⟨s1.st, Or.inr ⟨hno, rfl⟩, heq⟩
  have hRstep : R.step S.c s ch = .ok (.ext ⟨.call cal regs sp stackR,
      ({ s1 with st := st2 } : R.RState).world⟩ { s1 with st := st2 }) :=
    step_call_of hi hf hsc hs1 hp hcalR hargsR hR1' hR2' hsretR
  have hsretR' := hsretR
  unfold SretW at hsretR'
  have hesc2 : st2.escaped = s1.st.escaped := by
    rcases hsretR' with ⟨n, dst, -, -, hw⟩ | ⟨-, heq⟩
    · obtain ⟨_, -, -, he, -⟩ := writeFrame_parts hw
      exact he
    · rw [heq]
  have hU2 : ∀ o, s1.st.frame o = .uninit → st2.frame o = .uninit := by
    intro o ho
    rcases hsretR' with ⟨n, dst, -, -, hw⟩ | ⟨-, heq⟩
    · obtain ⟨_, -, -, -, hfrm⟩ := writeFrame_parts hw
      rw [hfrm o]
      split
      · exact getD_replicate_uninit _ _
      · exact ho
    · rw [heq]; exact ho
  -- the sret destination is `Uninit` after the write
  have hsretU : ∀ o, InFrame S o → s1.st.escapedAt o = none →
      C.fl.uninit[s.pc]!.bits.testBit (bit S o) = true → st2.frame o = .uninit := by
    intro o hif hpr hb
    obtain ⟨m, sd, hm, hsd, h1, h2⟩ := hunin _ hb
    have hm' : S.c.sretSize s.pc = some m := h.facts.sret _ _ hm
    have hca : Frame.callArgs [.slot dd, fo, .imm k, .words ws] = ws := by
      cases fo with
      | words ws0 =>
        simp [R.callee, OpSem.illFormed, throw, throwThe, MonadExceptOf.throw] at hcalR
      | _ => simp [Frame.callArgs]
    have hsd' : Frame.sretDest ws = some sd := by rw [hca] at hsd; exact hsd
    obtain ⟨r1, r2⟩ := in_range_of_bit hif h1 h2
    rcases hsretR' with ⟨n, dst, hn, hdst, hw⟩ | ⟨hno, -⟩
    · rw [hpc, hm'] at hn
      cases hn
      rw [hsd'] at hdst
      cases hdst
      obtain ⟨_, -, -, -, hfrm⟩ := writeFrame_parts hw
      rw [hfrm o]
      split
      · exact getD_replicate_uninit _ _
      · rename_i hnp
        exfalso
        apply hnp
        unfold OpSem.State.privateIn
        rw [hpr]
        simp only [List.length_replicate, Option.isNone_none, Bool.and_true, decide_eq_true_eq]
        constructor <;> omega
    · exact (hno m sd (by rw [hpc]; exact hm') hsd').elim
  -- a byte an `End` before the call covers, or `Uninit` already
  have hEnd : ∀ o, InFrame S o → s.st.escapedAt o = none → Dead S C s.pc o →
      C.fl.ends[s.pc]!.bits.testBit (bit S o) = true → st2.frame o = .uninit := by
    intro o hif hpriv hdead heb
    rw [hends] at heb
    obtain ⟨sc, hsc', hk, h1, h2⟩ := end_scope_of_bit hif heb
    exact hU2 o (private_fold _ hs1 hpriv
      (fun sc hsc a hka hcov => not_dead_of_escape C hlt hsc hka hcov.1 hcov.2 hdead)
      (.inr ⟨sc, hsc', hk, h1, h2⟩))
  have hUninit : ∀ o, s.st.escapedAt o = none → s.st.byteAt o = .ok .uninit →
      st2.frame o = .uninit := by
    intro o hpriv hb
    refine hU2 o (foldlM_frame_uninit _ hs1 ?_)
    simp only [OpSem.State.byteAt, hpriv] at hb
    exact Except.ok.inj hb
  -- a killed byte is one of the result's parts
  have hkillW : ∀ o, InFrame S o → C.fl.kill[s.pc]!.bits.testBit (bit S o) = true →
      ∃ x ∈ parts, dd.toInt + x.1.off ≤ o ∧ o < dd.toInt + x.1.off + x.1.size := by
    intro o hif hb
    rw [hkill, testBit_rangesBits] at hb
    obtain ⟨r, hr, hri⟩ := List.any_eq_true.1 hb
    rcases opndRanges_kill_aux _ _ _ _ ([], []) r hr with hr | ⟨off, m, hm, rfl⟩
    · cases hr
    simp only [Bool.and_eq_true, decide_eq_true_eq] at hri
    obtain ⟨b1, b2⟩ := in_range_of_bit hif hri.1 hri.2
    rw [hops] at hm
    rcases List.mem_append.1 hm with hm | hm
    rotate_left
    · exact (argPairs_no_write _ hm).elim
    rcases List.mem_append.1 hm with hm | hm
    · obtain ⟨m', hm'⟩ := hAread _ hm
      cases hm'
    · by_cases hk0 : k.toNat = 0
      · simp [hk0] at hm
      · simp only [hk0, ↓reduceIte] at hm
        obtain ⟨qq, hqq, hx⟩ := List.mem_map.1 hm
        simp only [Prod.mk.injEq, Frame.Access.write.injEq] at hx
        obtain ⟨rfl, rfl⟩ := hx
        obtain ⟨rr, hrr⟩ := hcover qq hqq
        obtain ⟨-, hbnd, -⟩ := Ryo.Proofs.CallLemmas.retRegsS_parts hp dd
        have hpo : Ryo.Proofs.CallLemmas.partOkS qq := (hbnd _ hrr).1
        have hq16 : qq.off + qq.size ≤ 16 := (hbnd _ hrr).2.2
        have hsz1 : 1 ≤ qq.size := by
          unfold Ryo.Proofs.CallLemmas.partOkS at hpo; split at hpo <;> omega
        have hdb := h.hyps.frameBounds.result s.pc op dd fo k ws f hi hf hsc
        have hK := h.hyps.frameBounds.K_le
        rw [Ryo.Proofs.CallLemmas.toInt_disp dd qq.off (by omega) (by omega)] at b1 b2
        exact ⟨(qq, rr), hrr, b1, b2⟩
  -- the answer from the shadow, and from `s`
  have hiU : S.c.d.insns[({ (erase s1 P) with st := eraseSt P st2 } : R.RState).pc]? =
      some (.native op [.slot dd, fo, .imm k, .words ws]) := hiS
  obtain ⟨stSh1, hwSh, hres⟩ := answer_call_ok hiU hf hsc ha
  let sh0 := (({ (erase s1 P) with st := eraseSt P st2 } : R.RState).withWorld a.world).st
  let r0 := (({ s1 with st := st2 } : R.RState).withWorld a.world).st
  have hrel0 : OpSem.FrameRel (eraseSt P st2).frame st2.frame sh0 r0 :=
    ⟨⟨rfl, rfl, rfl, rfl, rfl⟩, fun o => .inr ⟨rfl, rfl⟩⟩
  have hwSh' : R.writeRanges sh0 (callRanges S.c s1.pc) (callNew S.c s1.pc a) = .ok stSh1 := hwSh
  have hrr := writeRanges_rel (rs := callRanges S.c s1.pc) (new := callNew S.c s1.pc a) hrel0
  rw [hwSh'] at hrr
  obtain ⟨stR1, hwR⟩ : ∃ stR1,
      R.writeRanges r0 (callRanges S.c s1.pc) (callNew S.c s1.pc a) = .ok stR1 := by
    cases hwR : R.writeRanges r0 (callRanges S.c s1.pc) (callNew S.c s1.pc a) with
    | error e => rw [hwR] at hrr; simp only [OpSem.ResultRel] at hrr
    | ok stR1 => exact ⟨stR1, rfl⟩
  rw [hwR] at hrr
  obtain ⟨he1, hw1⟩ := writeRanges_pair (a := sh0) (b := r0) rfl hwSh' hwR
  have hescR1 : stR1.escaped = st2.escaped :=
    (writeRanges_pair (a := r0) (b := sh0) rfl hwR hwSh').1
  have he1' : stSh1.escaped = st2.escaped := he1
  have hsh1 : ∀ o, st2.escapedAt o = none → stSh1.escapedAt o = none := by
    intro o hpr
    unfold OpSem.State.escapedAt at hpr ⊢
    rw [he1']
    exact hpr
  have hiR : S.c.d.insns[({ s1 with st := st2 } : R.RState).pc]? =
      some (.native op [.slot dd, fo, .imm k, .words ws]) := hiS
  have hwR' : R.writeRanges (({ s1 with st := st2 } : R.RState).withWorld a.world).st
      (callRanges S.c ({ s1 with st := st2 } : R.RState).pc)
      (callNew S.c ({ s1 with st := st2 } : R.RState).pc a) = .ok stR1 := hwR
  obtain ⟨hRret, hRunw⟩ := answer_call_of hiR hf hsc hwR'
  have hpr1 : ∀ o, st2.escapedAt o = none → s1.st.escapedAt o = none := by
    intro o hpr
    unfold OpSem.State.escapedAt at hpr ⊢
    rw [← hesc2]
    exact hpr
  rcases hres with ⟨rregs, parts', stSh2, hres, hp', hfSh, hto⟩ | ⟨exc, hres, hunw⟩
  · -- the next instruction
    have hpp : parts' = parts := by
      rw [hp] at hp'
      exact (Except.ok.inj hp').symm
    rw [hpp] at hfSh
    cases hto
    have hrr2 := fold_rel_gen (F := fun st (q : Asm.RetPart × R.Reg) =>
        st.writeFrame (dd.toInt + q.1.off) ((rregs.get q.2).take q.1.size))
      (fun a b x hab => OpSem.writeFrame_rel hab) parts stSh1 stR1 hrr
    rw [hfSh] at hrr2
    obtain ⟨stR2, hfR⟩ : ∃ stR2, parts.foldlM (init := stR1) (fun st (q : Asm.RetPart × R.Reg) =>
        st.writeFrame (dd.toInt + q.1.off) ((rregs.get q.2).take q.1.size)) = .ok stR2 := by
      cases hfR : parts.foldlM (init := stR1) (fun st (q : Asm.RetPart × R.Reg) =>
          st.writeFrame (dd.toInt + q.1.off) ((rregs.get q.2).take q.1.size)) with
      | error e => rw [hfR] at hrr2; simp only [OpSem.ResultRel] at hrr2
      | ok stR2 => exact ⟨stR2, rfl⟩
    rw [hfR] at hrr2
    have hsbR : stR2.SameButFrame stSh2 :=
      ⟨hrr2.1.1.symm, hrr2.1.2.1.symm, hrr2.1.2.2.1.symm, hrr2.1.2.2.2.1.symm,
        hrr2.1.2.2.2.2.symm⟩
    obtain ⟨he2, hw2⟩ := fold_pair_gen
      (F := fun st (q : Asm.RetPart × R.Reg) =>
        st.writeFrame (dd.toInt + q.1.off) ((rregs.get q.2).take q.1.size))
      (fun q : Asm.RetPart × R.Reg => dd.toInt + q.1.off)
      (fun q : Asm.RetPart × R.Reg => (rregs.get q.2).take q.1.size) (fun _ _ _ hh => hh)
      parts stSh1 stR1 stSh2 stR2 (he1'.trans hescR1.symm) hfSh hfR
    have hescR2 : stR2.escaped = st2.escaped :=
      (fold_pair_gen
        (F := fun st (q : Asm.RetPart × R.Reg) =>
          st.writeFrame (dd.toInt + q.1.off) ((rregs.get q.2).take q.1.size))
        (fun q : Asm.RetPart × R.Reg => dd.toInt + q.1.off)
        (fun q : Asm.RetPart × R.Reg => (rregs.get q.2).take q.1.size) (fun _ _ _ hh => hh)
        parts stR1 stSh1 stR2 stSh2 (hescR1.trans he1'.symm) hfR hfSh).1.trans hescR1
    have hRn : RNext S.c s ⟨s1.pc + 1, s1.fp, stR2, s1.args⟩ :=
      RNext.answer hRstep (hRret rregs parts stR2 hres hp hfR)
    let Wr : Int → Prop := fun o =>
      (∃ p ∈ (callRanges S.c s1.pc).zip (callNew S.c s1.pc a),
          sh0.privateIn p.1.1 p.2.length o = true) ∨
        (∃ x ∈ parts, stSh1.privateIn (dd.toInt + x.1.off)
          ((rregs.get x.2).take x.1.size).length o = true)
    have hwr : ∀ o, Wr o → stR2.frame o = stSh2.frame o := by
      intro o hwo
      by_cases hf2 : ∃ x ∈ parts, stSh1.privateIn (dd.toInt + x.1.off)
          ((rregs.get x.2).take x.1.size).length o = true
      · exact ((hw2 o).1 hf2).symm
      · have hf2' : ∀ x ∈ parts, stSh1.privateIn (dd.toInt + x.1.off)
            ((rregs.get x.2).take x.1.size).length o = false := by
          intro x hx
          cases hb : stSh1.privateIn (dd.toInt + x.1.off) ((rregs.get x.2).take x.1.size).length o
          · rfl
          · exact (hf2 ⟨x, hx, hb⟩).elim
        rcases hwo with hl | hl
        · obtain ⟨h1, h2⟩ := (hw2 o).2 hf2'
          rw [h1, h2]
          exact ((hw1 o).1 hl).symm
        · exact (hf2 hl).elim
    have hnw : ∀ o, ¬ Wr o → stR2.frame o = st2.frame o ∧
        stSh2.frame o = (eraseSt P st2).frame o := by
      intro o hwo
      have hf2' : ∀ x ∈ parts, stSh1.privateIn (dd.toInt + x.1.off)
          ((rregs.get x.2).take x.1.size).length o = false := by
        intro x hx
        cases hb : stSh1.privateIn (dd.toInt + x.1.off) ((rregs.get x.2).take x.1.size).length o
        · rfl
        · exact (hwo (.inr ⟨x, hx, hb⟩)).elim
      have hl' : ∀ p ∈ (callRanges S.c s1.pc).zip (callNew S.c s1.pc a),
          sh0.privateIn p.1.1 p.2.length o = false := by
        intro p hp
        cases hb : sh0.privateIn p.1.1 p.2.length o
        · rfl
        · exact (hwo (.inl ⟨p, hp, hb⟩)).elim
      obtain ⟨h1, h2⟩ := (hw2 o).2 hf2'
      obtain ⟨h3, h4⟩ := (hw1 o).2 hl'
      exact ⟨h2.trans h4, h1.trans h3⟩
    have htin : s.pc + 1 < S.c.d.insns.size → s.pc + 1 ∈ C.fl.succ[s.pc]! := fun hyl => by
      rw [hsucc]; exact flow_succ_next_call hi hshr hyl
    refine stepOut_core C h (s1 := ({ s1 with st := st2 } : R.RState)) hRn rfl rfl rfl hsbR
      hescR2 Wr hwr hnw ?_ ?_ (.inr ?_)
      (fun o hpo _ hpr _ _ heb => hU2 o ((ends_noGhost C h hs1 hends hpo heb).resolve_left
        (fun hne => hne (hpr1 o hpr))))
    · intro o hpo hwo hpr hnd
      have hnd' : ¬ Dead S C (s.pc + 1) o := by rw [← hpc]; exact hnd
      obtain ⟨hif, -, hpriv, hd⟩ := h.patch o hpo
      rcases hd with hdead | ⟨hb, -⟩
      · have hlive : (C.fl.liveIn[s.pc + 1]!).testBit (bit S o) = true := by
          cases hb : (C.fl.liveIn[s.pc + 1]!).testBit (bit S o)
          · exact (hnd' ⟨hif, hb⟩).elim
          · rfl
        have hyl := lt_of_live C hlive
        by_cases hkb : C.fl.kill[s.pc]!.bits.testBit (bit S o) = true
        · exfalso
          obtain ⟨x, hx, b1, b2⟩ := hkillW o hif hkb
          apply hwo
          refine .inr ⟨x, hx, ?_⟩
          have hlen : ((rregs.get x.2).take x.1.size).length = x.1.size := by
            obtain ⟨-, hbnd, -⟩ := Ryo.Proofs.CallLemmas.retRegsS_parts hp dd
            have hw := part_le_width (hbnd x hx).1 (hbnd x hx).2.1
            have hl := hok.2 rregs hres x.2
            rw [List.length_take]
            omega
          unfold OpSem.State.privateIn
          rw [hsh1 o hpr, hlen]
          simp only [Option.isNone_none, Bool.and_true, decide_eq_true_eq]
          constructor <;> omega
        by_cases hub : C.fl.uninit[s.pc]!.bits.testBit (bit S o) = true
        · exact hsretU o hif (hpr1 o hpr) hub
        by_cases heb : C.fl.ends[s.pc]!.bits.testBit (bit S o) = true
        · exact hEnd o hif hpriv hdead heb
        · exfalso
          have := live_succ C.hlive hkk (htin hyl) hlive (by simpa using hkb) (by simpa using hub)
            (by simpa using heb)
          rw [hdead.2] at this
          cases this
      · exact hUninit o hpriv hb
    · intro hyl
      unfold EscSound
      show EscPre S.c.d C.fl.esc (s1.pc + 1) stR2
      rw [hpc]
      have hedge : s.pc + 1 ∈ C.fl.edges[s.pc]! := by
        rw [hedges]; exact List.mem_append_left _ (htin (by rw [← hpc]; exact hyl))
      exact escPre_next C.hesc hlt h.esc hs1 (hescR2.trans hesc2) hedge
    · intro o hpo hwo hpr hif
      cases hkb : C.fl.kill[s.pc]!.bits.testBit (bit S o)
      · rfl
      · exfalso
        obtain ⟨x, hx, b1, b2⟩ := hkillW o hif hkb
        apply hwo
        refine .inr ⟨x, hx, ?_⟩
        have hlen : ((rregs.get x.2).take x.1.size).length = x.1.size := by
          obtain ⟨-, hbnd, -⟩ := Ryo.Proofs.CallLemmas.retRegsS_parts hp dd
          have hw := part_le_width (hbnd x hx).1 (hbnd x hx).2.1
          have hl := hok.2 rregs hres x.2
          rw [List.length_take]
          omega
        unfold OpSem.State.privateIn
        rw [hsh1 o hpr, hlen]
        simp only [Option.isNone_none, Bool.and_true, decide_eq_true_eq]
        constructor <;> omega
  · -- unwinding
    obtain ⟨pad, b, hcl, rfl⟩ := unwindAt_step hunw
    have hcl' : S.c.cleanupAt s.pc = some (some pad, b) := by rw [← hpc]; exact hcl
    have hpin : pad ∈ C.fl.pad[s.pc]! := by
      rw [flowOf_pad C.hfl]; exact flow_pad_mem hcl' hlt (h.padRange pad b hcl')
    have hRu := unwindAt_of (c := S.c)
      (u := { (({ s1 with st := st2 } : R.RState).withWorld a.world) with st := stR1 })
      (exc := exc) hcl
    have hRn := RNext.answer hRstep ((hRunw exc hres).trans hRu)
    have hsbR : stR1.SameButFrame stSh1 :=
      ⟨hrr.1.1.symm, hrr.1.2.1.symm, hrr.1.2.2.1.symm, hrr.1.2.2.2.1.symm, hrr.1.2.2.2.2.symm⟩
    let Wr : Int → Prop := fun o => ∃ p ∈ (callRanges S.c s1.pc).zip (callNew S.c s1.pc a),
      sh0.privateIn p.1.1 p.2.length o = true
    have hwr : ∀ o, Wr o → stR1.frame o = stSh1.frame o := fun o hwo => ((hw1 o).1 hwo).symm
    have hnw : ∀ o, ¬ Wr o → stR1.frame o = st2.frame o ∧
        stSh1.frame o = (eraseSt P st2).frame o := by
      intro o hwo
      have hl' : ∀ p ∈ (callRanges S.c s1.pc).zip (callNew S.c s1.pc a),
          sh0.privateIn p.1.1 p.2.length o = false := by
        intro p hp
        cases hb : sh0.privateIn p.1.1 p.2.length o
        · rfl
        · exact (hwo ⟨p, hp, hb⟩).elim
      obtain ⟨h3, h4⟩ := (hw1 o).2 hl'
      exact ⟨h4, h3⟩
    refine stepOut_core C h (s1 := ({ s1 with st := st2 } : R.RState)) hRn rfl rfl rfl
      ⟨hsbR.1, hsbR.2.1, hsbR.2.2.1, rfl, hsbR.2.2.2.2⟩ hescR1 Wr hwr hnw ?_ ?_
      (.inl hpin)
      (fun o hpo _ hpr _ _ heb => hU2 o ((ends_noGhost C h hs1 hends hpo heb).resolve_left
        (fun hne => hne (hpr1 o hpr))))
    · intro o hpo hwo hpr hnd
      obtain ⟨hif, -, hpriv, hd⟩ := h.patch o hpo
      rcases hd with hdead | ⟨hb, -⟩
      · have hlive : (C.fl.liveIn[pad]!).testBit (bit S o) = true := by
          cases hb : (C.fl.liveIn[pad]!).testBit (bit S o)
          · exact (hnd ⟨hif, hb⟩).elim
          · rfl
        by_cases hub : C.fl.uninit[s.pc]!.bits.testBit (bit S o) = true
        · exact hsretU o hif (hpr1 o hpr) hub
        by_cases heb : C.fl.ends[s.pc]!.bits.testBit (bit S o) = true
        · exact hEnd o hif hpriv hdead heb
        · exfalso
          have := live_pad C.hlive hkk hpin hlive (by simpa using hub) (by simpa using heb)
          rw [hdead.2] at this
          cases this
      · exact hUninit o hpriv hb
    · intro _
      have hedge : pad ∈ C.fl.edges[s.pc]! := by
        rw [hedges]; exact List.mem_append_right _ hpin
      exact escPre_next C.hesc hlt h.esc hs1 (hescR1.trans hesc2) hedge

/-- T3b: a call (its answer; tail calls and `ret` have no `RNext`). -/
theorem rnext_erase_call (C : Cert S) {s t' : R.RState} {P : Int → Prop} (h : StepPre S C s P)
    (hc : CallLike S s.pc) (hans : ∀ ch q s1 a, R.step S.c (erase s P) ch = .ok (.ext q s1) →
      R.answer S.c s1 a = .ok (.step t') → AnswerOk S s a)
    (hn : RNext S.c (erase s P) t') : StepOut S C s P t' := by
  obtain ⟨op, ops, hi, hsh⟩ := hc
  have hi' : S.c.d.insns[(erase s P).pc]? = some (.native op ops) := hi
  obtain ⟨ch0, o0, hstep0⟩ : ∃ ch o, R.step S.c (erase s P) ch = .ok o := by
    cases hn with
    | step hs => exact ⟨_, _, hs⟩
    | answer hs _ => exact ⟨_, _, hs⟩
  cases hf : op.full with
  | none =>
    exfalso
    unfold R.step at hstep0
    simp only [hi', bind, Except.bind] at hstep0
    cases hsc : (S.c.scopesAt (erase s P).pc).foldlM R.applyScope (erase s P) with
    | error e => simp [hsc] at hstep0
    | ok s1 => simp [hsc, hf, OpSem.illFormed, throw, throwThe, MonadExceptOf.throw] at hstep0
  | some f =>
    have hshr := reduced_shape hf
    obtain ⟨hcs, hts, hrs⟩ := step_call_shape hi' hf hstep0
    -- a tail call or `ret` ends the function
    have hend : f.info.shape = .tailCall ∨ f.info.shape = .ret →
        ∀ ch o, R.step S.c (erase s P) ch = .ok o → ∃ fin, o = .done fin := by
      intro hsh' ch o hs
      rcases hsh' with hsh' | hsh'
      · obtain ⟨fo, ws, rfl⟩ := hts hsh'
        obtain ⟨_, _, _, _, _, _, _, _, hfin⟩ := step_tailCall_done hi' hf hsh' hs
        exact ⟨_, hfin⟩
      · obtain ⟨src, kk, rfl⟩ := hrs hsh'
        obtain ⟨_, _, _, _, _, _, _, _, hfin⟩ := Ryo.Proofs.ArgRet.step_ret hi' hf hsh' hs
        exact ⟨_, hfin⟩
    have hnot : f.info.shape = .tailCall ∨ f.info.shape = .ret → False := by
      intro hsh'
      cases hn with
      | step hs =>
        obtain ⟨_, hc⟩ := hend hsh' _ _ hs
        cases hc
      | answer hs _ =>
        obtain ⟨_, hc⟩ := hend hsh' _ _ hs
        cases hc
    rcases hsh with hsc | hsc | hsc
    · have hsc' : f.info.shape = .call := hshr.symm.trans hsc
      obtain ⟨dd, fo, k, ws, rfl⟩ := hcs hsc'
      exact rnext_erase_call' C h hi hf hsc' hans (h.callNext op _ f hi hf hsc') hn
    · exact (hnot (.inl (hshr.symm.trans hsc))).elim
    · exact (hnot (.inr (hshr.symm.trans hsc))).elim

/-- T3c: the other non-inline natives (island, `arg`, `jmp`, `lpad`, `resume`, `unreachable`). -/
theorem rnext_erase_other (C : Cert S) {s t' : R.RState} {P : Int → Prop} (h : StepPre S C s P)
    (hnat : ∃ op ops, S.c.d.insns[s.pc]? = some (.native op ops)) (hc : ¬ CallLike S s.pc)
    (hans : ∀ ch q s1 a, R.step S.c (erase s P) ch = .ok (.ext q s1) →
      R.answer S.c s1 a = .ok (.step t') → AnswerOk S s a)
    (hn : RNext S.c (erase s P) t') : StepOut S C s P t' := by
  obtain ⟨op, ops, hi⟩ := hnat
  have hi' : S.c.d.insns[(erase s P).pc]? = some (.native op ops) := hi
  have hst : ∃ ch o, R.step S.c (erase s P) ch = .ok o := by
    cases hn with
    | step hs => exact ⟨_, _, hs⟩
    | answer hs _ => exact ⟨_, _, hs⟩
  obtain ⟨ch, o, hstep⟩ := hst
  cases hf : op.full with
  | none =>
    exfalso
    unfold R.step at hstep
    simp only [hi', bind, Except.bind] at hstep
    cases hsc : (S.c.scopesAt (erase s P).pc).foldlM R.applyScope (erase s P) with
    | error e => simp [hsc] at hstep
    | ok s1 => simp [hsc, hf, OpSem.illFormed, throw, throwThe, MonadExceptOf.throw] at hstep
  | some f =>
    obtain ⟨hj, ha, his⟩ := step_native_shape hi' hf hstep
    by_cases hsj : f.info.shape = .jmp
    · obtain ⟨tg, rfl⟩ := hj hsj
      exact rnext_erase_jmp C h hi hf hsj (h.jmpRange op f tg hi hf hsj) hn
    by_cases hsa : f.info.shape = .arg
    · obtain ⟨d, r, rfl⟩ := ha hsa
      exact rnext_erase_arg C h hi hf hsa (h.argNext op f d r hi hf hsa)
        (fun a ha => h.argLen op f d r a hi hf hsa (h.argLead op f d r hi hf hsa) ha) hn
    by_cases hsi : f.info.shape = .island
    · obtain ⟨isl, ws, rfl⟩ := his hsi
      exact rnext_erase_island C h hi hf hsi hans hn
    have hshr := reduced_shape hf
    have hcall : f.info.shape ≠ .call ∧ f.info.shape ≠ .tailCall ∧ f.info.shape ≠ .ret := by
      refine ⟨fun hx => hc ⟨op, ops, hi, .inl (hshr.trans hx)⟩,
        fun hx => hc ⟨op, ops, hi, .inr (.inl (hshr.trans hx))⟩,
        fun hx => hc ⟨op, ops, hi, .inr (.inr (hshr.trans hx))⟩⟩
    exact rnext_erase_native_op C h hi hf hsj hsa hsi hcall hn

/-- T3a (assembly of the three): any non-inline instruction. -/
theorem rnext_erase (C : Cert S) {s t' : R.RState} {P : Int → Prop} (h : StepPre S C s P)
    (hans : ∀ ch q s1 a, R.step S.c (erase s P) ch = .ok (.ext q s1) →
      R.answer S.c s1 a = .ok (.step t') → AnswerOk S s a)
    (hn : RNext S.c (erase s P) t') : StepOut S C s P t' := by
  have hlt : s.pc < S.c.d.insns.size := h.lt
  have hi : S.c.d.insns[s.pc]? = some S.c.d.insns[s.pc] := Array.getElem?_eq_getElem hlt
  cases hk : S.c.d.insns[s.pc] with
  | handler f args t =>
    exact rnext_erase_handler C h ⟨f, args, t, by simp only [hi, hk]⟩ hn
  | native op ops =>
    rcases Classical.em (CallLike S s.pc) with hc | hc
    · exact rnext_erase_call C h hc hans hn
    · exact rnext_erase_other C h ⟨op, ops, by simp only [hi, hk]⟩ hc hans hn

/-! ### The function's end: `ret` and tail calls (T3b) -/

theorem foldlM_ext {α β : Type} {F G : β → α → OpSem.M β} :
    ∀ (l : List α) (i : β), (∀ x ∈ l, ∀ b, F b x = G b x) → l.foldlM F i = l.foldlM G i
  | [], _, _ => rfl
  | x :: l, i, h => by
    simp only [List.foldlM_cons]
    rw [h x (List.mem_cons_self ..) i]
    congr 1
    funext b
    exact foldlM_ext l b (fun y hy => h y (List.mem_cons_of_mem _ hy))

theorem fold_agree {α β : Type} {F G : β → α → OpSem.M β} {l : List α} {i : β}
    {r r' : OpSem.M β} (h : ∀ x ∈ l, ∀ b, F b x = G b x) (hF : l.foldlM F i = r)
    (hG : l.foldlM G i = r') : r = r' := by
  rw [← hF, ← hG]
  exact foldlM_ext l i h

theorem retParts_lt_true {k : Nat} {ab : Option Asm.RetPart × Option Asm.RetPart}
    (h : Asm.retParts k true = some ab) : k < 2 ^ 32 := by
  rw [Ryo.Proofs.ArgRet.retParts_eq] at h
  by_cases h24 : (k >>> 24 != 0) = true
  · simp [h24] at h
  · have h0 : k >>> 24 = 0 := by simpa using h24
    rw [Nat.shiftRight_eq_div_pow] at h0
    have e24 : (2 : Nat) ^ 24 = 16777216 := rfl
    have e32 : (2 : Nat) ^ 32 = 4294967296 := rfl
    rw [e24] at h0
    rw [e32]
    omega

/-- `retRegs`' parts (load form) are `retParts`'. -/
theorem retRegs_fst_true {k : Nat} {parts : List (Asm.RetPart × R.Reg)}
    (h : R.retRegs k true = .ok parts) :
    ∃ a b, Asm.retParts k true = some (a, b) ∧ ∀ q ∈ parts, q.1 ∈ [a, b].filterMap id := by
  unfold R.retRegs at h
  cases hk : Asm.retParts k true with
  | none => simp [hk, OpSem.illFormed, throw, throwThe, MonadExceptOf.throw] at h
  | some ab =>
    obtain ⟨a, b⟩ := ab
    simp only [hk, pure, Except.pure, Except.ok.injEq] at h
    subst h
    refine ⟨a, b, rfl, ?_⟩
    cases a with
    | none => cases b with
      | none => simp
      | some pb => cases hx : pb.xmm <;> simp [hx]
    | some pa => cases b with
      | none => cases hx : pa.xmm <;> simp [hx]
      | some pb => cases hx : pa.xmm <;> cases hy : pb.xmm <;> simp [hx, hy]

theorem foldl_max_ge : ∀ (l : List Asm.RetPart) (t : Nat),
    t ≤ l.foldl (fun x p => max x (p.off + p.size)) t ∧
      ∀ p ∈ l, p.off + p.size ≤ l.foldl (fun x p => max x (p.off + p.size)) t
  | [], t => ⟨Nat.le_refl _, fun _ h => by cases h⟩
  | q :: l, t => by
    obtain ⟨h1, h2⟩ := foldl_max_ge l (max t (q.off + q.size))
    simp only [List.foldl_cons]
    refine ⟨by omega, fun p hp => ?_⟩
    rcases List.mem_cons.1 hp with hpq | hp
    · subst hpq; omega
    · exact h2 p hp

/-- At a non-inline tail call: its operand reads and its `ends`. -/
theorem flowOf_tail_row {d : Decoded} {mode : Ryo.Obj.Mode} {facts : Frame.Facts}
    {fl : Frame.Flow} (h : Frame.Flow.of d mode facts = .ok fl) {k : Nat} {op : Reduced.Opcode}
    {ops : List (Opnd Nat)} (hi : d.insns[k]? = some (.native op ops))
    (hni : (op.full.bind Asm.classOf).isSome = false) (hc : op.info.shape = .tailCall) :
    ∃ eb, (∀ r ∈ (Frame.Flow.opndRanges d.frameSize true eb
        (Frame.native op ops mode.pe (Frame.Flow.lendsOf (Frame.scopesAt d) k)
          (facts.islandTemplate k)).opnds).1, r ∈ fl.operand[k]!) ∧
      fl.ends[k]! = (Frame.scopesAt d)[k]!.filterMap fun (_, sc) =>
        if sc.kind == .end then some (Frame.range d.frameSize sc.frameOffset sc.size) else none := by
  have hk : k < d.insns.size := by
    rcases Nat.lt_or_ge k d.insns.size with h | h
    · exact h
    · rw [Array.getElem?_eq_none h] at hi; cases hi
  have hik : d.insns[k]! = .native op ops := by
    rw [getElem!_pos d.insns k hk]
    rw [Array.getElem?_eq_getElem hk] at hi
    exact Option.some.inj hi
  have hc1 : (op.info.shape == .call || op.info.shape == .tailCall) = true := by rw [hc]; rfl
  obtain ⟨e, he, eb, -, -, hen, hop⟩ := flowOf_row4 h hk
  rw [hik] at he
  simp only [Frame.effects, hni, Bool.false_eq_true, ↓reduceIte, pure, Except.pure,
    Except.ok.injEq] at he
  subst he
  refine ⟨eb, fun r hr => ?_, ?_⟩
  · rw [hop]
    simp only [Frame.Flow.rowOf, Frame.Flow.callInfo, hik, hc1]
    exact List.mem_append_left _ hr
  · rw [hen]
    all_goals rfl

/-- T3b: `ret` from the shadow ends as from `s` (the parts read are live or `Uninit`; the
incoming area is above the frame). -/
theorem rdone_ret (C : Cert S) {s : R.RState} {P : Int → Prop} (h : StepPre S C s P)
    {op : Reduced.Opcode} {ops : List (Opnd Nat)} {f : Full.Opcode}
    (hi : S.c.d.insns[s.pc]? = some (.native op ops)) (hf : op.full = some f)
    (hsr : f.info.shape = .ret) {fin : R.Final} (hd : RDone S.c (erase s P) fin) :
    RDone S.c s fin := by
  have hi' : S.c.d.insns[(erase s P).pc]? = some (.native op ops) := hi
  obtain ⟨ch, hstep⟩ : ∃ ch, R.step S.c (erase s P) ch = .ok (.done fin) := by
    cases hd with
    | step hs => exact ⟨_, hs⟩
    | answer hs _ =>
      obtain ⟨-, -, hrs⟩ := step_call_shape hi' hf hs
      obtain ⟨src, kk, rfl⟩ := hrs hsr
      obtain ⟨_, _, _, _, _, _, _, _, hc⟩ := Ryo.Proofs.ArgRet.step_ret hi' hf hsr hs
      cases hc
  obtain ⟨-, -, hrs⟩ := step_call_shape hi' hf hstep
  obtain ⟨src, k, rfl⟩ := hrs hsr
  obtain ⟨s1e, parts, regs, incoming, hscE, hp, hg, hin, hfin⟩ :=
    Ryo.Proofs.ArgRet.step_ret hi' hf hsr hstep
  cases hfin
  obtain ⟨s1, hs1, rfl⟩ := scopes_erase_eq C h hscE
  have hshr : op.info.shape = .ret := (reduced_shape hf).trans hsr
  have hni : (op.full.bind Asm.classOf).isSome = false := by
    cases hb : (op.full.bind Asm.classOf).isSome
    · rfl
    · exact (h.notInline ⟨op, _, hi, hb⟩).elim
  have hc1 : (op.info.shape == .call) = false := by rw [hshr]; rfl
  have hc2 : (op.info.shape == .tailCall) = false := by rw [hshr]; rfl
  obtain ⟨eb, -, -, hsub, hends⟩ := flowOf_native_row C.hfl hi hni hc1 hc2
  -- the parts' bytes agree
  have hread : ∀ p r, (p, r) ∈ parts →
      (erase s1 P).st.readFrame (src.toInt + ↑p.off) p.size =
        s1.st.readFrame (src.toInt + ↑p.off) p.size := by
    intro p r hpr
    obtain ⟨a, b, hrp, hmem⟩ := retRegs_fst_true hp
    have hpa : p ∈ [a, b].filterMap id := hmem _ hpr
    have hk32 := retParts_lt_true hrp
    have hk0 : k.toNat ≠ 0 := by
      intro hk0
      rw [hk0, show Asm.retParts 0 true = some (none, none) from rfl] at hrp
      cases hrp
      simp at hpa
    have hops := native_ret_opnds hf hsr src k S.c.mode.pe
      (Frame.Flow.lendsOf (Frame.scopesAt S.c.d) s.pc) (C.facts.islandTemplate s.pc) hk32 hrp
    rw [if_neg hk0] at hops
    have hge := (foldl_max_ge ([a, b].filterMap id) 0).2 p hpa
    generalize ([a, b].filterMap id).foldl (fun x p => max x (p.off + p.size)) 0 = hv at hops hge
    have hmem : ((src, Frame.Access.read hv) : BitVec 32 × Frame.Access) ∈
        (Frame.native op [.slot src, .imm k] S.c.mode.pe
          (Frame.Flow.lendsOf (Frame.scopesAt S.c.d) s.pc) (C.facts.islandTemplate s.pc)).opnds := by
      rw [hops]; exact List.mem_singleton_self _
    apply readFrame_erase_of
    intro o h1 h2 hpo _
    obtain ⟨hif, -, -, -⟩ := h.patch o hpo
    have hs1' : src.toInt ≤ o := by omega
    have hs2' : o < src.toInt + (hv : Int) := by omega
    obtain ⟨b1, b2⟩ := bit_in_range (off := src) (n := hv) hif hs1' hs2'
    have hiF : bit S o < S.c.d.frameSize := by simp only [Frame.range] at b2; omega
    have hc := opndRanges_read_cover S.c.d.frameSize false eb hiF _ ([], [])
      (.inr ⟨(src, Frame.Access.read hv), hmem, hv, rfl, b1, b2⟩)
    exact read_uninit C h hs1 hends hpo (gen_of_operand_mem hsub hc)
  -- the incoming area is above the frame
  have hE : (eraseSt P s1.st).readFrame 16 S.c.argSize = s1.st.readFrame 16 S.c.argSize :=
    readFrame_erase_of (fun o h1 _ hpo _ => absurd (h.patch o hpo).1.2 (by omega))
  have hin' : s1.st.readFrame 16 S.c.argSize = .ok incoming := by rw [← hE]; exact hin
  refine RDone.step (ch := ch) ?_
  unfold R.step
  simp only [hi, bind, Except.bind, hs1, hf, hsr, hp]
  split
  · rename_i e hG
    have := fold_agree (fun x hx b => by
      obtain ⟨p, r⟩ := x
      dsimp only
      (try rw [hread p r hx]) <;> rfl) hg hG
    cases this
  · rename_i regs' hG
    have := fold_agree (fun x hx b => by
      obtain ⟨p, r⟩ := x
      dsimp only
      (try rw [hread p r hx]) <;> rfl) hg hG
    cases this
    rw [hin']
    all_goals rfl

/-- T3b: a tail call from the shadow ends as from `s` (the callee slot and the arguments read
are live or `Uninit`; the stack arguments are above the frame). -/
theorem rdone_tail (C : Cert S) {s : R.RState} {P : Int → Prop} (h : StepPre S C s P)
    {op : Reduced.Opcode} {ops : List (Opnd Nat)} {f : Full.Opcode}
    (hi : S.c.d.insns[s.pc]? = some (.native op ops)) (hf : op.full = some f)
    (hst : f.info.shape = .tailCall) {fin : R.Final} (hd : RDone S.c (erase s P) fin) :
    RDone S.c s fin := by
  have hi' : S.c.d.insns[(erase s P).pc]? = some (.native op ops) := hi
  obtain ⟨ch, hstep⟩ : ∃ ch, R.step S.c (erase s P) ch = .ok (.done fin) := by
    cases hd with
    | step hs => exact ⟨_, hs⟩
    | answer hs _ =>
      obtain ⟨-, hts, -⟩ := step_call_shape hi' hf hs
      obtain ⟨fo, ws, rfl⟩ := hts hst
      obtain ⟨_, _, _, _, _, _, _, _, hc⟩ := step_tailCall_done hi' hf hst hs
      cases hc
  obtain ⟨-, hts, -⟩ := step_call_shape hi' hf hstep
  obtain ⟨fo, ws, rfl⟩ := hts hst
  obtain ⟨s1e, cal, regs, stack, hscE, hc, ha, hrd, hfin⟩ := step_tailCall_done hi' hf hst hstep
  cases hfin
  obtain ⟨s1, hs1, rfl⟩ := scopes_erase_eq C h hscE
  have hshr : op.info.shape = .tailCall := (reduced_shape hf).trans hst
  have hni : (op.full.bind Asm.classOf).isSome = false := by
    cases hb : (op.full.bind Asm.classOf).isSome
    · rfl
    · exact (h.notInline ⟨op, _, hi, hb⟩).elim
  obtain ⟨eb, hsub, hends⟩ := flowOf_tail_row C.hfl hi hni hshr
  obtain ⟨A, hops, hAread, hAp⟩ := native_tail_opnds hf hst fo ws S.c.mode.pe
    (Frame.Flow.lendsOf (Frame.scopesAt S.c.d) s.pc) (C.facts.islandTemplate s.pc)
  have hcov : ∀ (x : BitVec 32 × Frame.Access) (m : Nat),
      x ∈ (Frame.native op [fo, .words ws] S.c.mode.pe
        (Frame.Flow.lendsOf (Frame.scopesAt S.c.d) s.pc) (C.facts.islandTemplate s.pc)).opnds →
      x.2 = .read m → (eraseSt P s1.st).readFrame x.1.toInt m = s1.st.readFrame x.1.toInt m := by
    intro x m hx hm
    refine call_read_agree C h hs1 hends hsub (fun i h1 h2 => ?_)
    have hiF : i < S.c.d.frameSize := by simp only [Frame.range] at h2; omega
    exact opndRanges_read_cover _ _ _ hiF _ ([], []) (.inr ⟨x, hx, m, hm, h1, h2⟩)
  have hcalR : R.callee s1.st f fo = .ok cal := by
    refine callee_erase (fun p hfo hcp => ?_) hc
    refine hcov (p, .read 8) 8 ?_ rfl
    rw [hops]
    exact List.mem_append_left _ (hAp hcp p hfo)
  have hargsR : R.argRegs s1.st ws = .ok regs := by
    refine argRegs_erase ws (fun x hx m hm => hcov x m ?_ hm) ha
    rw [hops]
    exact List.mem_append_right _ hx
  have hE : (eraseSt P s1.st).readFrame 16 (S.c.stackSize s1.pc) =
      s1.st.readFrame 16 (S.c.stackSize s1.pc) :=
    readFrame_erase_of (fun o h1 _ hpo _ => absurd (h.patch o hpo).1.2 (by omega))
  have hrdR : s1.st.readFrame 16 (S.c.stackSize s1.pc) = .ok stack := by rw [← hE]; exact hrd
  refine RDone.step (ch := ch) ?_
  unfold R.step
  simp only [hi, bind, Except.bind, hs1, hf, hst, hcalR, hargsR, hrdR]
  all_goals rfl

/-! ### The function's end: unwinding out, `resume`, the rest (T3b) -/

theorem exit_congr {u v : R.RState} {e : R.Exit} (h1 : u.st.mem = v.st.mem)
    (h2 : u.st.escaped = v.st.escaped) (h3 : u.st.exposed = v.st.exposed) :
    R.exit u e = R.exit v e := by
  unfold R.exit
  rw [h1, h2, h3]

theorem unwindAt_done {c : R.Code} {u : R.RState} {exc : ThinPointer} {fin : R.Final}
    (h : R.unwindAt c u exc = .ok (.done fin)) :
    ∃ b, c.cleanupAt u.pc = some (none, b) ∧ fin = R.exit u (.unwind exc) := by
  unfold R.unwindAt at h
  cases hcl : c.cleanupAt u.pc with
  | none => rw [hcl] at h; simp [OpSem.ub, throw, throwThe, MonadExceptOf.throw] at h
  | some cb =>
    obtain ⟨opad, b⟩ := cb
    cases opad with
    | none =>
      rw [hcl] at h
      simp only [pure, Except.pure, Except.ok.injEq, R.Out.done.injEq] at h
      exact ⟨b, rfl, h.symm⟩
    | some pad =>
      rw [hcl] at h
      simp only [pure, Except.pure, Except.ok.injEq] at h
      cases h

theorem unwindAt_done_of {c : R.Code} {u : R.RState} {exc : ThinPointer} {b : Bool}
    (hcl : c.cleanupAt u.pc = some (none, b)) :
    R.unwindAt c u exc = .ok (.done (R.exit u (.unwind exc))) := by
  unfold R.unwindAt
  simp only [hcl]
  all_goals rfl

/-- A native that isn't a call, tail call, `ret` or island only steps. -/
theorem step_plain_step {c : R.Code} {s : R.RState} {ch : OpSem.Choice} {o : R.Out}
    {op : Reduced.Opcode} {ops : List (Opnd Nat)} {f : Full.Opcode}
    (hi : c.d.insns[s.pc]? = some (.native op ops)) (hf : op.full = some f)
    (hsc : f.info.shape ≠ .call ∧ f.info.shape ≠ .tailCall ∧ f.info.shape ≠ .ret)
    (hsi : f.info.shape ≠ .island) (h : R.step c s ch = .ok o) : ∃ t, o = .step t := by
  obtain ⟨hj, ha, -⟩ := step_native_shape hi hf h
  by_cases hsj : f.info.shape = .jmp
  · obtain ⟨tg, rfl⟩ := hj hsj
    obtain ⟨_, _, hc⟩ := step_jmp_ok hi hf hsj h
    exact ⟨_, hc⟩
  by_cases hsa : f.info.shape = .arg
  · obtain ⟨d, r, rfl⟩ := ha hsa
    obtain ⟨_, _, _, _, _, _, hc⟩ := step_arg_ok hi hf hsa h
    exact ⟨_, hc⟩
  have hos := opShape_of_ne hsj hsa hsi hsc
  obtain ⟨s1, -, hsv⟩ := Ryo.Proofs.Step.step_native hi hf hos h
  by_cases hun : f = .unreachable
  · exfalso
    unfold R.stepView at hsv
    cases hv : R.view c.mode c.ρ (.native op ops) with
    | none =>
      rw [hv] at hsv
      simp [OpSem.illFormed, throw, throwThe, MonadExceptOf.throw] at hsv
    | some v =>
      obtain ⟨vals, t, -, -, rfl⟩ := Ryo.Proofs.Step.view_native hf hos hv
      rw [hv] at hsv
      subst hun
      simp [Ryo.Proofs.Shapes.unreachable_ne_resume, OpSem.illFormed, throw, throwThe,
        MonadExceptOf.throw] at hsv
  · obtain ⟨_, _, _, _, _, _, _, _, _, hc⟩ :=
      Ryo.Proofs.Step.stepView_native hf hos (reduced_ne_resume hf) hun hsv
    exact ⟨_, hc⟩

/-- T3b: `resume` unwinding out of the function from the shadow is R's own. -/
theorem rdone_resume (C : Cert S) {s : R.RState} {P : Int → Prop} (h : StepPre S C s P)
    {args : List R.Arg} {t : R.Then Nat}
    (hi : S.c.d.insns[s.pc]? = some (.handler .resume args t)) {fin : R.Final}
    (hd : RDone S.c (erase s P) fin) : RDone S.c s fin := by
  have hi' : S.c.d.insns[(erase s P).pc]? = some (.handler .resume args t) := hi
  have key : ∀ ch o, R.step S.c (erase s P) ch = .ok o → ∃ s1 v x bs p,
      (S.c.scopesAt s.pc).foldlM R.applyScope (erase s P) = .ok s1 ∧
      R.view S.c.mode S.c.ρ (.handler .resume args t) = some v ∧ v.ops = [.slot x] ∧
      s1.st.readFrame x 8 = .ok bs ∧ OpSem.asPtr bs = .ok p ∧ R.unwindAt S.c s1 p = .ok o := by
    intro ch o hst
    obtain ⟨s1, hsc⟩ := step_scopes_ok hst
    rw [Ryo.Proofs.Shapes.step_handler hi' hsc] at hst
    obtain ⟨v, x, bs, p, hv, hx, hrf, hap, hun⟩ := stepView_resume_ok hst
    exact ⟨s1, v, x, bs, p, hsc, hv, hx, hrf, hap, hun⟩
  obtain ⟨ch, hstep⟩ : ∃ ch, R.step S.c (erase s P) ch = .ok (.done fin) := by
    cases hd with
    | step hs => exact ⟨_, hs⟩
    | answer hs _ =>
      obtain ⟨_, _, _, _, _, _, _, _, _, _, hun⟩ := key _ _ hs
      unfold R.unwindAt at hun
      split at hun <;> simp [OpSem.ub, throw, throwThe, MonadExceptOf.throw, pure, Except.pure] at hun
  obtain ⟨t1, v, x, bs, p, hsc, hview, hx, hrf, hap, hunw⟩ := key _ _ hstep
  obtain ⟨s1, hs1, rfl⟩ := scopes_erase_eq C h hsc
  obtain ⟨e, eb, he, -, -, hsub, hends⟩ := flowOf_handler_row C.hfl hi
  have hu := view_handler_unpack hview
  obtain ⟨-, -, hRes⟩ := handlerVals_agree S.c.d.frameSize eb hu he
  have hrd : ∀ o, x ≤ o → o < x + 8 → P o → s1.st.frame o = .uninit := by
    intro o h1 h2 hpo
    obtain ⟨hif, -, -, -⟩ := h.patch o hpo
    exact read_uninit C h hs1 hends hpo
      (gen_of_operand_mem hsub (hRes rfl x hx o hif.1 hif.2 h1 h2))
  have hrf2 : s1.st.readFrame x 8 = .ok bs := by
    rw [← readFrame_erase_of (fun o h1 h2 hpo _ => hrd o h1 (by omega) hpo)]
    exact hrf
  obtain ⟨b, hcl, rfl⟩ := unwindAt_done hunw
  refine RDone.step (ch := ch) ?_
  rw [Ryo.Proofs.Shapes.step_handler hi hs1]
  unfold R.stepView
  have hctl := (view_handler hview).2
  have h1 : (v.op == .resume) = true := by simp [(view_handler hview).1]
  simp only [hview, hctl, h1, ↓reduceIte, bind, Except.bind, hx, hrf2, hap]
  exact unwindAt_done_of (c := S.c) (u := s1) (exc := p) hcl

/-- T3b: an island unwinding out of the function from the shadow is R's own. -/
theorem rdone_island (C : Cert S) {s : R.RState} {P : Int → Prop} (h : StepPre S C s P)
    {op : Reduced.Opcode} {f : Full.Opcode} {isl : Nat} {ws : List (BitVec 32)}
    (hi : S.c.d.insns[s.pc]? = some (.native op [.sym isl, .words ws])) (hf : op.full = some f)
    (hsi : f.info.shape = .island) {fin : R.Final} (hd : RDone S.c (erase s P) fin) :
    RDone S.c s fin := by
  have hi' : S.c.d.insns[(erase s P).pc]? = some (.native op [.sym isl, .words ws]) := hi
  obtain ⟨ch, q, t1, a, hstep, ha⟩ : ∃ ch q t1 a, R.step S.c (erase s P) ch = .ok (.ext q t1) ∧
      R.answer S.c t1 a = .ok (.done fin) := by
    cases hd with
    | step hs =>
      obtain ⟨_, _, hc⟩ := step_island_ok hi' hf hsi hs
      cases hc
    | answer hs ha => exact ⟨_, _, _, _, hs, ha⟩
  obtain ⟨t1', hsc, hq⟩ := step_island_ok hi' hf hsi hstep
  cases hq
  obtain ⟨s1, hs1, rfl⟩ := scopes_erase_eq C h hsc
  have hpc : s1.pc = s.pc := (Ryo.Proofs.Scope.scopes_keeps _ hs1).pc
  have hi1 : S.c.d.insns[(erase s1 P).pc]? = some (.native op [.sym isl, .words ws]) := by
    show S.c.d.insns[s1.pc]? = _
    rw [hpc]; exact hi
  have hiR : S.c.d.insns[s1.pc]? = some (.native op [.sym isl, .words ws]) := hi1
  obtain ⟨stSh, hwSh, hres⟩ := answer_island_ok hi1 hf hsi ha
  let sh0 := ((erase s1 P).withWorld a.world).st
  let r0 := (s1.withWorld a.world).st
  have hrel0 : OpSem.FrameRel (eraseSt P s1.st).frame s1.st.frame sh0 r0 :=
    ⟨⟨rfl, rfl, rfl, rfl, rfl⟩, fun o => .inr ⟨rfl, rfl⟩⟩
  have hrr := islandWrites_rel (c := S.c) (k := s1.pc) (new := a.frame) hrel0
  have hwSh' : S.c.islandWrites s1.pc sh0 a.frame = .ok stSh := hwSh
  rw [hwSh'] at hrr
  obtain ⟨stR, hwR⟩ : ∃ stR, S.c.islandWrites s1.pc r0 a.frame = .ok stR := by
    cases hwR : S.c.islandWrites s1.pc r0 a.frame with
    | error e => rw [hwR] at hrr; simp only [OpSem.ResultRel] at hrr
    | ok stR => exact ⟨stR, rfl⟩
  rw [hwR] at hrr
  obtain ⟨-, hRunw⟩ := answer_island_of hiR hf hsi hwR
  rcases hres with ⟨regs, hr, ht⟩ | ⟨exc, hr, hunw⟩
  · cases ht
  · obtain ⟨b, hcl, rfl⟩ := unwindAt_done hunw
    refine RDone.answer (step_island_of (ch := ch) hi hf hsi hs1) ((hRunw exc hr).trans ?_)
    rw [unwindAt_done_of (c := S.c) (u := { (s1.withWorld a.world) with st := stR })
      (exc := exc) hcl]
    rw [exit_congr (u := { (s1.withWorld a.world) with st := stR })
      (v := { ((erase s1 P).withWorld a.world) with st := stSh }) hrr.1.2.1.symm
      hrr.1.1.symm hrr.1.2.2.1.symm]

/-- T3b: a call unwinding out of the function from the shadow is R's own. -/
theorem rdone_call (C : Cert S) {s : R.RState} {P : Int → Prop} (h : StepPre S C s P)
    {op : Reduced.Opcode} {f : Full.Opcode} {dd : BitVec 32} {fo : Opnd Nat} {k : BitVec 64}
    {ws : List (BitVec 32)}
    (hi : S.c.d.insns[s.pc]? = some (.native op [.slot dd, fo, .imm k, .words ws]))
    (hf : op.full = some f) (hsc : f.info.shape = .call) {fin : R.Final}
    (hd : RDone S.c (erase s P) fin) : RDone S.c s fin := by
  have hi' : S.c.d.insns[(erase s P).pc]? = some (.native op [.slot dd, fo, .imm k, .words ws]) :=
    hi
  obtain ⟨ch, q, t1, a, hstep, ha⟩ : ∃ ch q t1 a, R.step S.c (erase s P) ch = .ok (.ext q t1) ∧
      R.answer S.c t1 a = .ok (.done fin) := by
    cases hd with
    | step hs =>
      obtain ⟨_, _, _, _, _, _, _, _, _, _, _, _, _, _, hc⟩ := step_call_ok hi' hf hsc hs
      cases hc
    | answer hs ha => exact ⟨_, _, _, _, hs, ha⟩
  obtain ⟨u1, parts, cal, regs, sp, stack, stS, hscS, hp, hcal, hargs, hR1, hR2, hsret, hq⟩ :=
    step_call_ok hi' hf hsc hstep
  cases hq
  obtain ⟨s1, hs1, rfl⟩ := scopes_erase_eq C h hscS
  have hpc : s1.pc = s.pc := (Ryo.Proofs.Scope.scopes_keeps _ hs1).pc
  have hlt := h.lt
  have hiS : S.c.d.insns[s1.pc]? = some (.native op [.slot dd, fo, .imm k, .words ws]) := by
    rw [hpc]; exact hi
  -- the row
  have hshr : op.info.shape = .call := (reduced_shape hf).trans hsc
  have hni : (op.full.bind Asm.classOf).isSome = false := by
    cases hb : (op.full.bind Asm.classOf).isSome
    · rfl
    · exact (h.notInline ⟨op, _, hi, hb⟩).elim
  obtain ⟨eb, hkill, hunin, hsub, hends⟩ := flowOf_call_row C.hfl hi hni hshr
  obtain ⟨pa, pb, hrp, hcover⟩ := retRegs_cover hp
  have hk32 : k.toNat < 2 ^ 32 := retParts_lt hrp
  obtain ⟨A, hops, hAread, hAp⟩ := native_call_opnds hf hsc dd fo k ws S.c.mode.pe
    (Frame.Flow.lendsOf (Frame.scopesAt S.c.d) s.pc) (C.facts.islandTemplate s.pc) hk32 hrp
  have hsucc : C.fl.succ = (Frame.flow S.c.d).1 := flowOf_succ C.hfl
  have hssz : C.fl.succ.size = S.c.d.insns.size := by rw [hsucc, flow_succ_size]
  have hpsz : C.fl.pad.size = C.fl.succ.size := (postFix_spec C.hlive).2.1
  have hkk : s.pc < C.fl.succ.size := by rw [hssz]; exact hlt
  have hedges := flow_edges_get hkk (by rw [hpsz]; exact hkk)
  -- the operand reads agree
  have hcov : ∀ (x : BitVec 32 × Frame.Access) (m : Nat),
      x ∈ (Frame.native op [.slot dd, fo, .imm k, .words ws] S.c.mode.pe
        (Frame.Flow.lendsOf (Frame.scopesAt S.c.d) s.pc) (C.facts.islandTemplate s.pc)).opnds →
      x.2 = .read m → (eraseSt P s1.st).readFrame x.1.toInt m = s1.st.readFrame x.1.toInt m := by
    intro x m hx hm
    refine call_read_agree C h hs1 hends hsub (fun i h1 h2 => ?_)
    have hiF : i < S.c.d.frameSize := by simp only [Frame.range] at h2; omega
    exact opndRanges_read_cover _ _ _ hiF _ ([], []) (.inr ⟨x, hx, m, hm, h1, h2⟩)
  have hcalR : R.callee s1.st f fo = .ok cal := by
    refine callee_erase (fun p hfo hcp => ?_) hcal
    refine hcov (p, .read 8) 8 ?_ rfl
    rw [hops]
    exact List.mem_append_left _ (List.mem_append_left _ (hAp hcp p hfo))
  have hargsR : R.argRegs s1.st ws = .ok regs := by
    refine argRegs_erase ws (fun x hx m hm => hcov x m ?_ hm) hargs
    rw [hops]
    exact List.mem_append_right _ hx
  -- the outgoing area and the sret write from `s1`
  obtain ⟨stackR, hR1', hR2'⟩ : ∃ stackR,
      (S.c.inRegion s1.pc = true → sp = ch.sp ∧
        stackR = List.replicate (S.c.stackSize s1.pc) AbstractByte.uninit) ∧
      (S.c.inRegion s1.pc = false → R.frameAddr s1.fp (-(S.c.d.frameSize : Int)) = .ok sp ∧
        s1.st.readFrame (-(S.c.d.frameSize : Int)) (S.c.stackSize s1.pc) = .ok stackR) := by
    cases hr : S.c.inRegion s1.pc with
    | true => exact ⟨_, fun _ => ⟨(hR1 hr).1, rfl⟩, (fun h' => by cases h')⟩
    | false =>
      obtain ⟨hfa, hrd⟩ := hR2 hr
      obtain ⟨st', hst'⟩ := readFrame_ok_erase hrd
      exact ⟨st', (fun h' => by cases h'), fun _ => ⟨hfa, hst'⟩⟩
  unfold SretW at hsret
  obtain ⟨st2, hsretR, rfl⟩ : ∃ st2, SretW S.c s1.pc ws s1.st st2 ∧ stS = eraseSt P st2 := by
    rcases hsret with ⟨n, dst, hn, hdst, hw⟩ | ⟨hno, heq⟩
    · obtain ⟨st2, hw2, rfl⟩ := writeFrame_erase hw
      exact ⟨st2, Or.inl ⟨n, dst, hn, hdst, hw2⟩, rfl⟩
    · exact ⟨s1.st, Or.inr ⟨hno, rfl⟩, heq⟩
  have hRstep : R.step S.c s ch = .ok (.ext ⟨.call cal regs sp stackR,
      ({ s1 with st := st2 } : R.RState).world⟩ { s1 with st := st2 }) :=
    step_call_of hi hf hsc hs1 hp hcalR hargsR hR1' hR2' hsretR
  have hsretR' := hsretR
  unfold SretW at hsretR'
  have hesc2 : st2.escaped = s1.st.escaped := by
    rcases hsretR' with ⟨n, dst, -, -, hw⟩ | ⟨-, heq⟩
    · obtain ⟨_, -, -, he, -⟩ := writeFrame_parts hw
      exact he
    · rw [heq]
  have hU2 : ∀ o, s1.st.frame o = .uninit → st2.frame o = .uninit := by
    intro o ho
    rcases hsretR' with ⟨n, dst, -, -, hw⟩ | ⟨-, heq⟩
    · obtain ⟨_, -, -, -, hfrm⟩ := writeFrame_parts hw
      rw [hfrm o]
      split
      · exact getD_replicate_uninit _ _
      · exact ho
    · rw [heq]; exact ho
  -- the sret destination is `Uninit` after the write
  have hsretU : ∀ o, InFrame S o → s1.st.escapedAt o = none →
      C.fl.uninit[s.pc]!.bits.testBit (bit S o) = true → st2.frame o = .uninit := by
    intro o hif hpr hb
    obtain ⟨m, sd, hm, hsd, h1, h2⟩ := hunin _ hb
    have hm' : S.c.sretSize s.pc = some m := h.facts.sret _ _ hm
    have hca : Frame.callArgs [.slot dd, fo, .imm k, .words ws] = ws := by
      cases fo with
      | words ws0 =>
        simp [R.callee, OpSem.illFormed, throw, throwThe, MonadExceptOf.throw] at hcalR
      | _ => simp [Frame.callArgs]
    have hsd' : Frame.sretDest ws = some sd := by rw [hca] at hsd; exact hsd
    obtain ⟨r1, r2⟩ := in_range_of_bit hif h1 h2
    rcases hsretR' with ⟨n, dst, hn, hdst, hw⟩ | ⟨hno, -⟩
    · rw [hpc, hm'] at hn
      cases hn
      rw [hsd'] at hdst
      cases hdst
      obtain ⟨_, -, -, -, hfrm⟩ := writeFrame_parts hw
      rw [hfrm o]
      split
      · exact getD_replicate_uninit _ _
      · rename_i hnp
        exfalso
        apply hnp
        unfold OpSem.State.privateIn
        rw [hpr]
        simp only [List.length_replicate, Option.isNone_none, Bool.and_true, decide_eq_true_eq]
        constructor <;> omega
    · exact (hno m sd (by rw [hpc]; exact hm') hsd').elim
  -- a byte an `End` before the call covers, or `Uninit` already
  have hEnd : ∀ o, InFrame S o → s.st.escapedAt o = none → Dead S C s.pc o →
      C.fl.ends[s.pc]!.bits.testBit (bit S o) = true → st2.frame o = .uninit := by
    intro o hif hpriv hdead heb
    rw [hends] at heb
    obtain ⟨sc, hsc', hk, h1, h2⟩ := end_scope_of_bit hif heb
    exact hU2 o (private_fold _ hs1 hpriv
      (fun sc hsc a hka hcov => not_dead_of_escape C hlt hsc hka hcov.1 hcov.2 hdead)
      (.inr ⟨sc, hsc', hk, h1, h2⟩))
  have hUninit : ∀ o, s.st.escapedAt o = none → s.st.byteAt o = .ok .uninit →
      st2.frame o = .uninit := by
    intro o hpriv hb
    refine hU2 o (foldlM_frame_uninit _ hs1 ?_)
    simp only [OpSem.State.byteAt, hpriv] at hb
    exact Except.ok.inj hb
  -- a killed byte is one of the result's parts
  have hkillW : ∀ o, InFrame S o → C.fl.kill[s.pc]!.bits.testBit (bit S o) = true →
      ∃ x ∈ parts, dd.toInt + x.1.off ≤ o ∧ o < dd.toInt + x.1.off + x.1.size := by
    intro o hif hb
    rw [hkill, testBit_rangesBits] at hb
    obtain ⟨r, hr, hri⟩ := List.any_eq_true.1 hb
    rcases opndRanges_kill_aux _ _ _ _ ([], []) r hr with hr | ⟨off, m, hm, rfl⟩
    · cases hr
    simp only [Bool.and_eq_true, decide_eq_true_eq] at hri
    obtain ⟨b1, b2⟩ := in_range_of_bit hif hri.1 hri.2
    rw [hops] at hm
    rcases List.mem_append.1 hm with hm | hm
    rotate_left
    · exact (argPairs_no_write _ hm).elim
    rcases List.mem_append.1 hm with hm | hm
    · obtain ⟨m', hm'⟩ := hAread _ hm
      cases hm'
    · by_cases hk0 : k.toNat = 0
      · simp [hk0] at hm
      · simp only [hk0, ↓reduceIte] at hm
        obtain ⟨qq, hqq, hx⟩ := List.mem_map.1 hm
        simp only [Prod.mk.injEq, Frame.Access.write.injEq] at hx
        obtain ⟨rfl, rfl⟩ := hx
        obtain ⟨rr, hrr⟩ := hcover qq hqq
        obtain ⟨-, hbnd, -⟩ := Ryo.Proofs.CallLemmas.retRegsS_parts hp dd
        have hpo : Ryo.Proofs.CallLemmas.partOkS qq := (hbnd _ hrr).1
        have hq16 : qq.off + qq.size ≤ 16 := (hbnd _ hrr).2.2
        have hsz1 : 1 ≤ qq.size := by
          unfold Ryo.Proofs.CallLemmas.partOkS at hpo; split at hpo <;> omega
        have hdb := h.hyps.frameBounds.result s.pc op dd fo k ws f hi hf hsc
        have hK := h.hyps.frameBounds.K_le
        rw [Ryo.Proofs.CallLemmas.toInt_disp dd qq.off (by omega) (by omega)] at b1 b2
        exact ⟨(qq, rr), hrr, b1, b2⟩
  -- the answer from the shadow, and from `s`
  have hiU : S.c.d.insns[({ (erase s1 P) with st := eraseSt P st2 } : R.RState).pc]? =
      some (.native op [.slot dd, fo, .imm k, .words ws]) := hiS
  obtain ⟨stSh1, hwSh, hres⟩ := answer_call_ok hiU hf hsc ha
  let sh0 := (({ (erase s1 P) with st := eraseSt P st2 } : R.RState).withWorld a.world).st
  let r0 := (({ s1 with st := st2 } : R.RState).withWorld a.world).st
  have hrel0 : OpSem.FrameRel (eraseSt P st2).frame st2.frame sh0 r0 :=
    ⟨⟨rfl, rfl, rfl, rfl, rfl⟩, fun o => .inr ⟨rfl, rfl⟩⟩
  have hwSh' : R.writeRanges sh0 (callRanges S.c s1.pc) (callNew S.c s1.pc a) = .ok stSh1 := hwSh
  have hrr := writeRanges_rel (rs := callRanges S.c s1.pc) (new := callNew S.c s1.pc a) hrel0
  rw [hwSh'] at hrr
  obtain ⟨stR1, hwR⟩ : ∃ stR1,
      R.writeRanges r0 (callRanges S.c s1.pc) (callNew S.c s1.pc a) = .ok stR1 := by
    cases hwR : R.writeRanges r0 (callRanges S.c s1.pc) (callNew S.c s1.pc a) with
    | error e => rw [hwR] at hrr; simp only [OpSem.ResultRel] at hrr
    | ok stR1 => exact ⟨stR1, rfl⟩
  rw [hwR] at hrr
  obtain ⟨he1, hw1⟩ := writeRanges_pair (a := sh0) (b := r0) rfl hwSh' hwR
  have hescR1 : stR1.escaped = st2.escaped :=
    (writeRanges_pair (a := r0) (b := sh0) rfl hwR hwSh').1
  have he1' : stSh1.escaped = st2.escaped := he1
  have hsh1 : ∀ o, st2.escapedAt o = none → stSh1.escapedAt o = none := by
    intro o hpr
    unfold OpSem.State.escapedAt at hpr ⊢
    rw [he1']
    exact hpr
  have hiR : S.c.d.insns[({ s1 with st := st2 } : R.RState).pc]? =
      some (.native op [.slot dd, fo, .imm k, .words ws]) := hiS
  have hwR' : R.writeRanges (({ s1 with st := st2 } : R.RState).withWorld a.world).st
      (callRanges S.c ({ s1 with st := st2 } : R.RState).pc)
      (callNew S.c ({ s1 with st := st2 } : R.RState).pc a) = .ok stR1 := hwR
  obtain ⟨hRret, hRunw⟩ := answer_call_of hiR hf hsc hwR'
  have hpr1 : ∀ o, st2.escapedAt o = none → s1.st.escapedAt o = none := by
    intro o hpr
    unfold OpSem.State.escapedAt at hpr ⊢
    rw [← hesc2]
    exact hpr
  rcases hres with ⟨rregs, parts', stSh2, hres, hp', hfSh, hto⟩ | ⟨exc, hres, hunw⟩
  · cases hto
  · obtain ⟨b, hcl, rfl⟩ := unwindAt_done hunw
    refine RDone.answer hRstep ((hRunw exc hres).trans ?_)
    rw [unwindAt_done_of (c := S.c)
      (u := { (({ s1 with st := st2 } : R.RState).withWorld a.world) with st := stR1 })
      (exc := exc) hcl]
    rw [exit_congr (u := { (({ s1 with st := st2 } : R.RState).withWorld a.world) with st := stR1 })
      (v := { (({ (erase s1 P) with st := eraseSt P st2 } : R.RState).withWorld a.world) with
        st := stSh1 }) hrr.1.2.1.symm hrr.1.1.symm hrr.1.2.2.1.symm]

/-- T3b: the function's end from the shadow is R's own (the same world: `P` holds no escaped
byte at a return or tail call, bytes `≥ 0` aren't tracked). -/
theorem rdone_erase (C : Cert S) {s : R.RState} {P : Int → Prop} (h : StepPre S C s P)
    {f : R.Final} (hd : RDone S.c (erase s P) f) : RDone S.c s f := by
  have hlt : s.pc < S.c.d.insns.size := h.lt
  have hi0 : S.c.d.insns[s.pc]? = some S.c.d.insns[s.pc] := Array.getElem?_eq_getElem hlt
  have hok0 : ∃ ch o, R.step S.c (erase s P) ch = .ok o := by
    cases hd with
    | step hs => exact ⟨_, _, hs⟩
    | answer hs _ => exact ⟨_, _, hs⟩
  obtain ⟨ch0, o0, hstep0⟩ := hok0
  have hnostep : (∀ ch o, R.step S.c (erase s P) ch = .ok o → ∃ t, o = .step t) → False := by
    intro key
    cases hd with
    | step hs =>
      obtain ⟨_, hc⟩ := key _ _ hs
      cases hc
    | answer hs _ =>
      obtain ⟨_, hc⟩ := key _ _ hs
      cases hc
  cases hk : S.c.d.insns[s.pc] with
  | handler hh args t =>
    have hi : S.c.d.insns[s.pc]? = some (.handler hh args t) := by simp only [hi0, hk]
    have hi' : S.c.d.insns[(erase s P).pc]? = some (.handler hh args t) := hi
    by_cases hres : hh = .resume
    · subst hres
      exact rdone_resume C h hi hd
    · refine (hnostep fun ch o hs => ?_).elim
      by_cases hun : hh = .unreachable
      · exfalso
        subst hun
        obtain ⟨s1, hsc⟩ := step_scopes_ok hs
        rw [Ryo.Proofs.Shapes.step_handler hi' hsc] at hs
        unfold R.stepView at hs
        cases hv : R.view S.c.mode S.c.ρ (.handler .unreachable args t) with
        | none =>
          rw [hv] at hs
          simp [OpSem.illFormed, throw, throwThe, MonadExceptOf.throw] at hs
        | some v =>
          have := view_handler_has hv
          rw [Ryo.Proofs.DecodeLink.noHandler.2.2.1] at this
          cases this
      · obtain ⟨_, _, _, _, _, _, _, _, _, _, _, _, hc⟩ := step_handler_ok hi' hres hun hs
        exact ⟨_, hc⟩
  | native op ops =>
    have hi : S.c.d.insns[s.pc]? = some (.native op ops) := by simp only [hi0, hk]
    have hi' : S.c.d.insns[(erase s P).pc]? = some (.native op ops) := hi
    cases hf : op.full with
    | none =>
      exfalso
      unfold R.step at hstep0
      simp only [hi', bind, Except.bind] at hstep0
      cases hsc : (S.c.scopesAt (erase s P).pc).foldlM R.applyScope (erase s P) with
      | error e => simp [hsc] at hstep0
      | ok s1 => simp [hsc, hf, OpSem.illFormed, throw, throwThe, MonadExceptOf.throw] at hstep0
    | some g =>
      by_cases hsr : g.info.shape = .ret
      · exact rdone_ret C h hi hf hsr hd
      by_cases hst : g.info.shape = .tailCall
      · exact rdone_tail C h hi hf hst hd
      obtain ⟨hcs, -, -⟩ := step_call_shape hi' hf hstep0
      by_cases hsc : g.info.shape = .call
      · obtain ⟨dd, fo, kk, ws, rfl⟩ := hcs hsc
        exact rdone_call C h hi hf hsc hd
      obtain ⟨-, -, his⟩ := step_native_shape hi' hf hstep0
      by_cases hsi : g.info.shape = .island
      · obtain ⟨isl, ws, rfl⟩ := his hsi
        exact rdone_island C h hi hf hsi hd
      exact (hnostep fun ch o hs => step_plain_step hi' hf ⟨hsc, hst, hsr⟩ hsi hs).elim

/-! ### Safety of the shadow's step: the scopes (T3b) -/

/-- A frame write fails the same way on states with the same escaped objects and memory. -/
theorem writeFrame_err {a b : OpSem.State} {off : Int} {bs : List AbstractByte} {e : OpSem.Stop}
    (h : a.writeFrame off bs = .error e) (hesc : a.escaped = b.escaped) (hmem : a.mem = b.mem) :
    b.writeFrame off bs = .error e := by
  unfold OpSem.State.writeFrame at h ⊢
  have hw : a.writeEscaped off bs = b.writeEscaped off bs := by
    simp only [OpSem.State.writeEscaped, OpSem.State.escapedAt, hesc, hmem]
  rw [hw] at h
  cases hm : b.writeEscaped off bs with
  | error e' =>
    rw [hm] at h
    exact h
  | ok m =>
    rw [hm] at h
    cases h

/-- `Escape` from the shadow fails as from `u` (the bytes it copies agree). -/
theorem escape_erase_err {u : R.RState} {P : Int → Prop} {off : Int} {size align : Nat}
    (hr : (eraseSt P u.st).readFrame off size = u.st.readFrame off size) {e : OpSem.Stop}
    (h : R.escape (erase u P) off size align = .error e) :
    R.escape u off size align = .error e := by
  unfold R.escape at h ⊢
  simp only [erase, eraseSt] at h hr ⊢
  by_cases hA : (u.st.escaped.any fun e => decide (e.off ≤ off ∧ off + ↑size ≤ e.off + ↑e.size)) = true
  · simp only [hA, ↓reduceIte] at h
    cases h
  simp only [hA, ↓reduceIte, Bool.false_eq_true] at h ⊢
  by_cases hB : (u.st.escaped.any fun e => decide (e.off < off + ↑size ∧ off < e.off + ↑e.size)) = true
  · simp only [hB, ↓reduceIte] at h ⊢
    exact h
  simp only [hB, ↓reduceIte, Bool.false_eq_true] at h ⊢
  cases hfa : R.frameAddr u.fp off with
  | error e' =>
    try rw [hfa] at h
    try rw [hfa]
    exact h
  | ok addr =>
    try rw [hfa] at h
    try rw [hfa]
    simp only [bind, Except.bind] at h ⊢
    by_cases hal : (!(Align.ofBytes align).isAligned addr) = true
    · simp only [hal, ↓reduceIte] at h ⊢
      exact h
    simp only [hal, ↓reduceIte, Bool.false_eq_true] at h ⊢
    by_cases hC : (u.st.mem.allocs.any fun a => a.live && a.overlaps addr size) = true
    · simp only [hC, ↓reduceIte] at h ⊢
      exact h
    simp only [hC, ↓reduceIte, Bool.false_eq_true] at h ⊢
    rw [hr] at h
    cases hrf : u.st.readFrame off size with
    | error e' =>
      try rw [hrf] at h
      try rw [hrf]
      exact h
    | ok bytes =>
      try rw [hrf] at h
      cases h

/-- `End` from the shadow fails as from `u`. -/
theorem storageEnd_erase_err {u : R.RState} {P : Int → Prop} {off : Int} {size : Nat}
    {e : OpSem.Stop} (h : R.storageEnd (erase u P) off size = .error e) :
    R.storageEnd u off size = .error e := by
  unfold R.storageEnd at h ⊢
  simp only [List.partition_eq_filter_filter, bind, Except.bind] at h ⊢
  split at h
  · rename_i e' he
    have he2 := writeFrame_err he (b := ({ u.st with
      mem := R.freeObjs u.st.mem
        (u.st.escaped.filter fun e => decide (off ≤ e.off ∧ e.off + e.size ≤ off + size)),
      escaped := u.st.escaped.filter
        (not ∘ fun e => decide (off ≤ e.off ∧ e.off + e.size ≤ off + size)) } : OpSem.State))
      rfl rfl
    split
    · rename_i e'' he''
      rw [he2] at he''
      cases he''
      exact h
    · rename_i st'' he''
      rw [he2] at he''
      cases he''
  · cases h

theorem applyScope_erase_err {P InEsc : Int → Prop} {u : R.RState} {sc : R.Scope}
    {e : OpSem.Stop} (hK : KInv P InEsc u.st)
    (hesc : ∀ a, sc.kind = .escape a → ∀ o, sc.frameOffset.toInt ≤ o →
      o < sc.frameOffset.toInt + sc.size → InEsc o)
    (h : R.applyScope (erase u P) sc = .error e) : R.applyScope u sc = .error e := by
  unfold R.applyScope at h ⊢
  split at h
  · rename_i a hk
    try simp only [hk]
    exact escape_erase_err (readFrame_erase hK (hesc a hk)) h
  · rename_i hk
    try simp only [hk]
    exact storageEnd_erase_err h
  · cases h

theorem scopes_erase_err_aux (P InEsc : Int → Prop) (x : X86.State) :
    ∀ (l : List R.Scope) {u : R.RState} {e : OpSem.Stop},
      (∀ sc ∈ l, ∀ a, sc.kind = .escape a → ∀ o, sc.frameOffset.toInt ≤ o →
        o < sc.frameOffset.toInt + sc.size → InEsc o) →
      Ryo.Proofs.Scope.RRel u x → KInv P InEsc u.st →
      l.foldlM R.applyScope (erase u P) = .error e → l.foldlM R.applyScope u = .error e
  | [], u, e, _, _, _, h => by cases h
  | sc :: l, u, e, hl, hr, hK, h => by
    simp only [List.foldlM_cons, bind, Except.bind] at h ⊢
    cases h1 : R.applyScope (erase u P) sc with
    | error e' =>
      rw [h1] at h
      rw [applyScope_erase_err hK (hl sc (List.mem_cons_self ..)) h1]
      exact h
    | ok v2 =>
      rw [h1] at h
      obtain ⟨u2, hu2, rfl, hK2⟩ :=
        applyScope_erase hr hK (hl sc (List.mem_cons_self ..)) h1
      rw [hu2]
      exact scopes_erase_err_aux P InEsc x l (fun sc' hs => hl sc' (List.mem_cons_of_mem _ hs))
        (Ryo.Proofs.Scope.rrel_applyScope hr hu2) hK2 h

/-- The scopes from the shadow fail as from `s`. -/
theorem scopes_erase_err (C : Cert S) {s : R.RState} {P : Int → Prop} (h : StepPre S C s P)
    {e : OpSem.Stop} (hsc : (S.c.scopesAt s.pc).foldlM R.applyScope (erase s P) = .error e) :
    (S.c.scopesAt s.pc).foldlM R.applyScope s = .error e := by
  obtain ⟨xh, hfr⟩ := h.frame
  have hr : Ryo.Proofs.Scope.RRel s (S.virt xh) := hfr.1.rrel
  let InEsc : Int → Prop := fun o => ∃ sc ∈ S.c.scopesAt s.pc, ∃ a, sc.kind = .escape a ∧
    sc.frameOffset.toInt ≤ o ∧ o < sc.frameOffset.toInt + sc.size
  have hK0 : KInv P InEsc s.st := by
    intro o ho
    obtain ⟨-, -, hpriv, hd⟩ := h.patch o ho
    refine .inl ⟨hpriv, fun hio => ?_⟩
    rcases hd with hdead | ⟨hb, -⟩
    · obtain ⟨sc, hsc, a, hk, h1, h2⟩ := hio
      exact (not_dead_of_escape C h.lt hsc hk h1 h2 hdead).elim
    · simp only [OpSem.State.byteAt, hpriv] at hb
      exact Except.ok.inj hb
  exact scopes_erase_err_aux P InEsc (S.virt xh) _
    (fun sc hsc a hk o h1 h2 => ⟨sc, hsc, a, hk, h1, h2⟩) hr hK0 hsc

/-- A step whose scopes fail fails with their error. -/
theorem step_scopes_err {c : R.Code} {u : R.RState} {ch : OpSem.Choice} {i : Insn}
    {e : OpSem.Stop} (hi : c.d.insns[u.pc]? = some i)
    (hsc : (c.scopesAt u.pc).foldlM R.applyScope u = .error e) : R.step c u ch = .error e := by
  unfold R.step
  simp only [hi, bind, Except.bind, hsc]

/-! ### Safety of the shadow's step: state-independent failures (T3b) -/

/-- A `jmp` or `arg` with the wrong operands fails, whatever the state. -/
theorem step_shape_bad {c : R.Code} {u u1 : R.RState} {ch : OpSem.Choice}
    {op : Reduced.Opcode} {ops : List (Opnd Nat)} {f : Full.Opcode}
    (hi : c.d.insns[u.pc]? = some (.native op ops)) (hf : op.full = some f)
    (hsc : (c.scopesAt u.pc).foldlM R.applyScope u = .ok u1)
    (hbad : (f.info.shape = .jmp ∧ ∀ t, ops ≠ [.target t]) ∨
      (f.info.shape = .arg ∧ ∀ d r, ops ≠ [.slot d, .imm r]) ∨
      (f.info.shape = .ret ∧ ∀ src k, ops ≠ [.slot src, .imm k]) ∨
      (f.info.shape = .tailCall ∧ ∀ fo ws, ops ≠ [fo, .words ws]) ∨
      (f.info.shape = .island ∧ ∀ isl ws, ops ≠ [.sym isl, .words ws]) ∨
      (f.info.shape = .call ∧ ∀ d fo k ws, ops ≠ [.slot d, fo, .imm k, .words ws])) :
    R.step c u ch = .error (.illFormed s!"{op.mnemonic}'s operands") := by
  unfold R.step
  simp only [hi, bind, Except.bind, hsc, hf]
  rcases hbad with ⟨hsh, hops⟩ | ⟨hsh, hops⟩ | ⟨hsh, hops⟩ | ⟨hsh, hops⟩ | ⟨hsh, hops⟩ |
    ⟨hsh, hops⟩ <;> rw [hsh] <;> split <;>
    first
    | exact absurd rfl (hops _)
    | exact absurd rfl (hops _ _)
    | exact absurd rfl (hops _ _ _ _)
    | (simp only [OpSem.illFormed, throw, throwThe, MonadExceptOf.throw]; done)
    | (exfalso; simp_all only [reduceCtorEq]; done)
    | (simp_all; done)

/-- `arg` from the shadow fails as from `s` (an unknown register, or the frame write). -/
theorem step_arg_err {c : R.Code} {s s1 : R.RState} {P : Int → Prop} {ch : OpSem.Choice}
    {op : Reduced.Opcode} {f : Full.Opcode} {d : BitVec 32} {r : BitVec 64} {e : OpSem.Stop}
    (hi : c.d.insns[s.pc]? = some (.native op [.slot d, .imm r])) (hf : op.full = some f)
    (hsh : f.info.shape = .arg) (hsc : (c.scopesAt s.pc).foldlM R.applyScope s = .ok s1)
    (hsce : (c.scopesAt (erase s P).pc).foldlM R.applyScope (erase s P) = .ok (erase s1 P))
    (he : R.step c (erase s P) ch = .error e) : R.step c s ch = .error e := by
  have hi' : c.d.insns[(erase s P).pc]? = some (.native op [.slot d, .imm r]) := hi
  unfold R.step at he ⊢
  simp only [hi', bind, Except.bind, hsce, hf] at he
  simp only [hi, bind, Except.bind, hsc, hf]
  rw [hsh] at he ⊢
  try dsimp only at he ⊢
  cases ha : Asm.ArgReg.of? r.toNat true with
  | none =>
    simp only [ha] at he ⊢
    exact he
  | some a =>
    simp only [ha, bind, Except.bind] at he ⊢
    cases hw : (erase s1 P).st.writeFrame d.toInt
        (((erase s1 P).args.get (.ofArgReg a)).take a.size) with
    | error e' =>
      rw [hw] at he
      have hw2 : s1.st.writeFrame d.toInt ((s1.args.get (.ofArgReg a)).take a.size) =
          .error e' := writeFrame_err hw rfl rfl
      rw [hw2]
      exact he
    | ok st =>
      rw [hw] at he
      cases he

/-- A view-less instruction fails the same way from states at the same instruction. -/
theorem stepView_none_eq {c : R.Code} {u u' : R.RState} {i : Insn} {ch : OpSem.Choice}
    (hv : R.view c.mode c.ρ i = none) (hpc : u.pc = u'.pc) :
    R.stepView c u i ch = R.stepView c u' i ch := by
  unfold R.stepView
  simp only [hv, hpc]

/-- A native `unreachable` fails the same way from states at the same instruction. -/
theorem stepView_unreach_eq {c : R.Code} {u u' : R.RState} {ch : OpSem.Choice}
    {op : Reduced.Opcode} {ops : List (Opnd Nat)} {f : Full.Opcode} (hf : op.full = some f)
    (hos : R.opShape f = true) (hun : f = .unreachable) (hpc : u.pc = u'.pc) :
    R.stepView c u (.native op ops) ch = R.stepView c u' (.native op ops) ch := by
  cases hv : R.view c.mode c.ρ (.native op ops) with
  | none => exact stepView_none_eq hv hpc
  | some v =>
    obtain ⟨vals, t, -, -, rfl⟩ := Ryo.Proofs.Step.view_native hf hos hv
    subst hun
    unfold R.stepView
    simp only [hv, Ryo.Proofs.Shapes.unreachable_ne_resume, beq_self_eq_true,
      Bool.false_eq_true, ↓reduceIte, bind, Except.bind, throw, throwThe, MonadExceptOf.throw]
    all_goals rfl

/-- The parts `ret` reads agree between the shadow and R after the scopes. -/
theorem ret_read_agree (C : Cert S) {s s1 : R.RState} {P : Int → Prop} (h : StepPre S C s P)
    {op : Reduced.Opcode} {f : Full.Opcode} {src : BitVec 32} {k : BitVec 64}
    (hi : S.c.d.insns[s.pc]? = some (.native op [.slot src, .imm k])) (hf : op.full = some f)
    (hsr : f.info.shape = .ret) (hs1 : (S.c.scopesAt s.pc).foldlM R.applyScope s = .ok s1)
    {parts : List (Asm.RetPart × R.Reg)} (hp : R.retRegs k.toNat true = .ok parts) :
    ∀ p r, (p, r) ∈ parts →
      (erase s1 P).st.readFrame (src.toInt + ↑p.off) p.size =
        s1.st.readFrame (src.toInt + ↑p.off) p.size := by
  have hshr : op.info.shape = .ret := (reduced_shape hf).trans hsr
  have hni : (op.full.bind Asm.classOf).isSome = false := by
    cases hb : (op.full.bind Asm.classOf).isSome
    · rfl
    · exact (h.notInline ⟨op, _, hi, hb⟩).elim
  have hc1 : (op.info.shape == .call) = false := by rw [hshr]; rfl
  have hc2 : (op.info.shape == .tailCall) = false := by rw [hshr]; rfl
  obtain ⟨eb, -, -, hsub, hends⟩ := flowOf_native_row C.hfl hi hni hc1 hc2
  intro p r hpr
  obtain ⟨a, b, hrp, hmem⟩ := retRegs_fst_true hp
  have hpa : p ∈ [a, b].filterMap id := hmem _ hpr
  have hk32 := retParts_lt_true hrp
  have hk0 : k.toNat ≠ 0 := by
    intro hk0
    rw [hk0, show Asm.retParts 0 true = some (none, none) from rfl] at hrp
    cases hrp
    simp at hpa
  have hops := native_ret_opnds hf hsr src k S.c.mode.pe
    (Frame.Flow.lendsOf (Frame.scopesAt S.c.d) s.pc) (C.facts.islandTemplate s.pc) hk32 hrp
  rw [if_neg hk0] at hops
  have hge := (foldl_max_ge ([a, b].filterMap id) 0).2 p hpa
  generalize ([a, b].filterMap id).foldl (fun x p => max x (p.off + p.size)) 0 = hv at hops hge
  have hmem : ((src, Frame.Access.read hv) : BitVec 32 × Frame.Access) ∈
      (Frame.native op [.slot src, .imm k] S.c.mode.pe
        (Frame.Flow.lendsOf (Frame.scopesAt S.c.d) s.pc) (C.facts.islandTemplate s.pc)).opnds := by
    rw [hops]; exact List.mem_singleton_self _
  apply readFrame_erase_of
  intro o h1 h2 hpo _
  obtain ⟨hif, -, -, -⟩ := h.patch o hpo
  have hs1' : src.toInt ≤ o := by omega
  have hs2' : o < src.toInt + (hv : Int) := by omega
  obtain ⟨b1, b2⟩ := bit_in_range (off := src) (n := hv) hif hs1' hs2'
  have hiF : bit S o < S.c.d.frameSize := by simp only [Frame.range] at b2; omega
  have hc := opndRanges_read_cover S.c.d.frameSize false eb hiF _ ([], [])
    (.inr ⟨(src, Frame.Access.read hv), hmem, hv, rfl, b1, b2⟩)
  exact read_uninit C h hs1 hends hpo (gen_of_operand_mem hsub hc)

/-- `ret` from the shadow fails as from `s`. -/
theorem rsafe_ret (C : Cert S) {s s1 : R.RState} {P : Int → Prop} (h : StepPre S C s P)
    {op : Reduced.Opcode} {f : Full.Opcode} {src : BitVec 32} {k : BitVec 64}
    (hi : S.c.d.insns[s.pc]? = some (.native op [.slot src, .imm k])) (hf : op.full = some f)
    (hsr : f.info.shape = .ret) (hs1 : (S.c.scopesAt s.pc).foldlM R.applyScope s = .ok s1)
    (hsce : (S.c.scopesAt (erase s P).pc).foldlM R.applyScope (erase s P) = .ok (erase s1 P))
    {ch : OpSem.Choice} {e : OpSem.Stop} (he : R.step S.c (erase s P) ch = .error e) :
    R.step S.c s ch = .error e := by
  have hi' : S.c.d.insns[(erase s P).pc]? = some (.native op [.slot src, .imm k]) := hi
  have hE : (eraseSt P s1.st).readFrame 16 S.c.argSize = s1.st.readFrame 16 S.c.argSize :=
    readFrame_erase_of (fun o h1 _ hpo _ => absurd (h.patch o hpo).1.2 (by omega))
  unfold R.step at he ⊢
  simp only [hi', bind, Except.bind, hsce, hf, hsr] at he
  simp only [hi, bind, Except.bind, hs1, hf, hsr]
  cases hp : R.retRegs k.toNat true with
  | error e' =>
    simp only [hp] at he ⊢
    exact he
  | ok parts =>
    have hread := ret_read_agree C h hi hf hsr hs1 hp
    simp only [hp] at he ⊢
    split at he
    · rename_i e1 hG1
      split
      · rename_i e2 hG2
        have := fold_agree (fun x hx b => by
          obtain ⟨p, r⟩ := x
          dsimp only
          (try rw [hread p r hx]) <;> rfl) hG1 hG2
        cases this
        exact he
      · rename_i regs2 hG2
        have := fold_agree (fun x hx b => by
          obtain ⟨p, r⟩ := x
          dsimp only
          (try rw [hread p r hx]) <;> rfl) hG1 hG2
        cases this
    · rename_i regs1 hG1
      split
      · rename_i e2 hG2
        have := fold_agree (fun x hx b => by
          obtain ⟨p, r⟩ := x
          dsimp only
          (try rw [hread p r hx]) <;> rfl) hG1 hG2
        cases this
      · rename_i regs2 hG2
        have := fold_agree (fun x hx b => by
          obtain ⟨p, r⟩ := x
          dsimp only
          (try rw [hread p r hx]) <;> rfl) hG1 hG2
        cases this
        rw [← hE]
        exact he

/-- `resume` from the shadow fails as from `u'` when the exception slot's bytes agree. -/
theorem stepView_resume_err {c : R.Code} {u u' : R.RState} {args : List R.Arg} {t : R.Then Nat}
    {ch : OpSem.Choice} {e : OpSem.Stop} (hpc : u.pc = u'.pc)
    (hrd : ∀ v x, R.view c.mode c.ρ (.handler .resume args t) = some v → v.ops = [.slot x] →
      u.st.readFrame x 8 = u'.st.readFrame x 8)
    (h : R.stepView c u (.handler .resume args t) ch = .error e) :
    R.stepView c u' (.handler .resume args t) ch = .error e := by
  unfold R.stepView at h ⊢
  cases hv : R.view c.mode c.ρ (.handler .resume args t) with
  | none =>
    simp only [hv] at h ⊢
    rw [← hpc]
    exact h
  | some v =>
    obtain ⟨hop, hctl⟩ := view_handler hv
    have h1 : (v.op == .resume) = true := by simp [hop]
    simp only [hv, hctl, h1, ↓reduceIte, bind, Except.bind] at h ⊢
    have hrd' := hrd v
    generalize hops : v.ops = ops at h ⊢ hrd'
    rcases ops with _ | ⟨o, _ | ⟨o2, rest⟩⟩
    · (first | exact h | (simp only [OpSem.illFormed, throw, throwThe, MonadExceptOf.throw] at h ⊢; exact h))
    · cases o
      case slot x =>
        try dsimp only at h ⊢
        rw [hrd' x hv rfl] at h
        cases hrf : u'.st.readFrame x 8 with
        | error e' =>
          rw [hrf] at h
          exact h
        | ok bs =>
          rw [hrf] at h
          try dsimp only at h ⊢
          cases hap : OpSem.asPtr bs with
          | error e' =>
            rw [hap] at h
            exact h
          | ok p =>
            rw [hap] at h
            try dsimp only at h ⊢
            unfold R.unwindAt at h ⊢
            rw [← hpc]
            cases hcl : c.cleanupAt u.pc with
            | none =>
              rw [hcl] at h
              exact h
            | some cb =>
              obtain ⟨opad, b⟩ := cb
              cases opad with
              | none =>
                rw [hcl] at h
                cases h
              | some pad =>
                rw [hcl] at h
                cases h
      all_goals (first | exact h | (simp only [OpSem.illFormed, throw, throwThe, MonadExceptOf.throw] at h ⊢; exact h))
    · (first | exact h | (simp only [OpSem.illFormed, throw, throwThe, MonadExceptOf.throw] at h ⊢; exact h))

/-! ### Safety of the shadow's step: tail calls (T3b) -/

theorem callee_erase_eq {P : Int → Prop} {st : OpSem.State} {f : Full.Opcode} {fo : Opnd Nat}
    (hrd : ∀ p, fo = .slot p → (f = .callPtr ∨ f = .tailCallPtr) →
      (eraseSt P st).readFrame p.toInt 8 = st.readFrame p.toInt 8) :
    R.callee (eraseSt P st) f fo = R.callee st f fo := by
  cases fo with
  | slot p =>
    unfold R.callee
    by_cases hc : (f == .callPtr || f == .tailCallPtr) = true
    · have hc' : f = .callPtr ∨ f = .tailCallPtr := by simpa using hc
      simp only [hc, ↓reduceIte]
      rw [hrd p rfl hc']
    · simp only [hc, Bool.false_eq_true, ↓reduceIte]
  | _ => rfl

theorem argRegs_erase_eq {P : Int → Prop} {st : OpSem.State} :
    ∀ (ws : List (BitVec 32)),
      (∀ x ∈ Frame.argPairs ws, ∀ m, x.2 = .read m →
        (eraseSt P st).readFrame x.1.toInt m = st.readFrame x.1.toInt m) →
      R.argRegs (eraseSt P st) ws = R.argRegs st ws
  | [], _ => rfl
  | [_], _ => rfl
  | s :: r :: rest, hrd => by
    have hrest : ∀ x ∈ Frame.argPairs rest, ∀ m, x.2 = .read m →
        (eraseSt P st).readFrame x.1.toInt m = st.readFrame x.1.toInt m :=
      fun x hx m hm => hrd x (by simp only [Frame.argPairs]; exact List.mem_cons_of_mem _ hx) m hm
    unfold R.argRegs
    rw [argRegs_erase_eq rest hrest]
    by_cases hb : (r.toNat &&& Asm.argAddr != 0) = true
    · simp only [hb, ↓reduceIte]
      rfl
    · simp only [hb, Bool.false_eq_true, ↓reduceIte]
      cases ha : Asm.ArgReg.of? r.toNat false with
      | none => rfl
      | some a =>
        simp only [ha]
        rw [hrd (s, .read a.size) (by simp [Frame.argPairs, hb, ha]) a.size rfl]

/-- A tail call from the shadow fails as from `s` (the reads agree). -/
theorem rsafe_tail (C : Cert S) {s s1 : R.RState} {P : Int → Prop} (h : StepPre S C s P)
    {op : Reduced.Opcode} {f : Full.Opcode} {fo : Opnd Nat} {ws : List (BitVec 32)}
    (hi : S.c.d.insns[s.pc]? = some (.native op [fo, .words ws])) (hf : op.full = some f)
    (hst : f.info.shape = .tailCall) (hs1 : (S.c.scopesAt s.pc).foldlM R.applyScope s = .ok s1)
    (hsce : (S.c.scopesAt (erase s P).pc).foldlM R.applyScope (erase s P) = .ok (erase s1 P))
    {ch : OpSem.Choice} {e : OpSem.Stop} (he : R.step S.c (erase s P) ch = .error e) :
    R.step S.c s ch = .error e := by
  have hi' : S.c.d.insns[(erase s P).pc]? = some (.native op [fo, .words ws]) := hi
  have hshr : op.info.shape = .tailCall := (reduced_shape hf).trans hst
  have hni : (op.full.bind Asm.classOf).isSome = false := by
    cases hb : (op.full.bind Asm.classOf).isSome
    · rfl
    · exact (h.notInline ⟨op, _, hi, hb⟩).elim
  obtain ⟨eb, hsub, hends⟩ := flowOf_tail_row C.hfl hi hni hshr
  obtain ⟨A, hops, hAread, hAp⟩ := native_tail_opnds hf hst fo ws S.c.mode.pe
    (Frame.Flow.lendsOf (Frame.scopesAt S.c.d) s.pc) (C.facts.islandTemplate s.pc)
  have hcov : ∀ (x : BitVec 32 × Frame.Access) (m : Nat),
      x ∈ (Frame.native op [fo, .words ws] S.c.mode.pe
        (Frame.Flow.lendsOf (Frame.scopesAt S.c.d) s.pc) (C.facts.islandTemplate s.pc)).opnds →
      x.2 = .read m → (eraseSt P s1.st).readFrame x.1.toInt m = s1.st.readFrame x.1.toInt m := by
    intro x m hx hm
    refine call_read_agree C h hs1 hends hsub (fun i h1 h2 => ?_)
    have hiF : i < S.c.d.frameSize := by simp only [Frame.range] at h2; omega
    exact opndRanges_read_cover _ _ _ hiF _ ([], []) (.inr ⟨x, hx, m, hm, h1, h2⟩)
  have hcalE : R.callee (erase s1 P).st f fo = R.callee s1.st f fo :=
    callee_erase_eq (fun p hfo hcp => hcov (p, .read 8) 8
      (by rw [hops]; exact List.mem_append_left _ (hAp hcp p hfo)) rfl)
  have hargE : R.argRegs (erase s1 P).st ws = R.argRegs s1.st ws :=
    argRegs_erase_eq ws (fun x hx m hm => hcov x m
      (by rw [hops]; exact List.mem_append_right _ hx) hm)
  have hE : (erase s1 P).st.readFrame 16 (S.c.stackSize (erase s1 P).pc) =
      s1.st.readFrame 16 (S.c.stackSize s1.pc) :=
    readFrame_erase_of (fun o h1 _ hpo _ => absurd (h.patch o hpo).1.2 (by omega))
  unfold R.step at he ⊢
  simp only [hi', bind, Except.bind, hsce, hf, hst] at he
  simp only [hi, bind, Except.bind, hs1, hf, hst]
  rw [hcalE, hargE, hE] at he
  exact he

/-! ### Safety of the shadow's step: calls (T3b) -/

/-- Instruction `k`'s stack-argument reads in `Flow.of`. -/
theorem flowOf_stack_row {d : Decoded} {mode : Ryo.Obj.Mode} {facts : Frame.Facts}
    {fl : Frame.Flow} (h : Frame.Flow.of d mode facts = .ok fl) {k : Nat} (hk : k < d.insns.size) :
    ∃ e, Frame.effects d.insns[k]! (d.items[k]?.getD []) mode
        (Frame.Flow.lendsOf (Frame.scopesAt d) k) (facts.islandTemplate k) = .ok e ∧
      ∃ eb, fl.stack[k]! = (Frame.Flow.rowOf d facts (Frame.scopesAt d) k e eb).stack := by
  unfold Frame.Flow.of at h
  simp only [bind, Except.bind] at h
  split at h
  · cases h
  · rename_i rows hr
    simp only [pure, Except.pure, Except.ok.injEq] at h
    subst h
    obtain ⟨r, hrow, hr2⟩ := mapM_except_ok _ _ rows hr k (by simpa using hk)
    simp only [List.getElem_range] at hrow
    unfold Frame.Flow.row at hrow
    simp only [bind, Except.bind] at hrow
    split at hrow
    · cases hrow
    · rename_i e he
      simp only [pure, Except.pure, Except.ok.injEq] at hrow
      obtain ⟨eb, hrow'⟩ : ∃ eb, Frame.Flow.rowOf d facts (Frame.scopesAt d) k e eb = r :=
        ⟨_, hrow⟩
      refine ⟨e, he, eb, ?_⟩
      rw [hrow']
      simp [Array.getElem!_eq_getD, Array.getD_eq_getD_getElem?, hr2]

/-- A bit of `k`'s stack-argument reads is in `gen k`. -/
theorem gen_of_stack_bit {fl : Frame.Flow} {k i : Nat}
    (hb : (Frame.Ranges.bits fl.stack[k]!).testBit i = true) : (fl.gen k).testBit i = true := by
  rw [testBit_rangesBits] at hb
  unfold Frame.Flow.gen Frame.Flow.direct
  rw [Nat.testBit_or, testBit_rangesBits, List.any_append]
  simp only [Bool.or_eq_true]
  exact .inl (.inr hb)

/-- A call's `readsAll`: whether it may have stack arguments. -/
theorem native_call_readsAll {op : Reduced.Opcode} {f : Full.Opcode} (hf : op.full = some f)
    (hs : f.info.shape = .call) (dd : BitVec 32) (fo : Opnd Nat) (k : BitVec 64)
    (ws : List (BitVec 32)) (pe : Bool) (lends : List (BitVec 32 × Nat)) (tmpl : Option String) :
    (Frame.native op [.slot dd, fo, .imm k, .words ws] pe lends tmpl).readsAll =
      Frame.mayHaveStackArgs pe ws := by
  obtain ⟨-, hn⟩ := reduced_call_ops hf hs
  have hshr : op.info.shape = .call := (reduced_shape hf).trans hs
  obtain ⟨o1, o2, o3, o4, hops, h1, h2, h3, h4⟩ : ∃ o1 o2 o3 o4,
      op.info.operands = [o1, o2, o3, o4] ∧ o1.name = "d" ∧
      o2.name = (if f = .callPtr then "p" else if f = .call then "f" else "sym") ∧
      o3.name = "k" ∧ o4.name = "a" := by
    cases hq : op.info.operands with
    | nil => rw [hq] at hn; cases hn
    | cons o1 t1 =>
      cases t1 with
      | nil => rw [hq] at hn; simp at hn
      | cons o2 t2 =>
        cases t2 with
        | nil => rw [hq] at hn; simp at hn
        | cons o3 t3 =>
          cases t3 with
          | nil => rw [hq] at hn; simp at hn
          | cons o4 t4 =>
            cases t4 with
            | cons _ _ => rw [hq] at hn; simp at hn
            | nil =>
              rw [hq] at hn
              simp only [List.map_cons, List.map_nil, List.cons.injEq, and_true] at hn
              exact ⟨o1, o2, o3, o4, rfl, hn.1, hn.2.1, hn.2.2.1, hn.2.2.2⟩
  unfold Frame.native
  by_cases hp : f = .callPtr
  · rw [if_pos hp] at h2
    simp [hshr, hops, h1, h2, h3, h4] <;> (try split) <;> (try split) <;> (try split) <;> rfl
  · rw [if_neg hp] at h2
    by_cases hc : f = .call
    · rw [if_pos hc] at h2
      simp [hshr, hops, h1, h2, h3, h4] <;> (try split) <;> (try split) <;> (try split) <;> rfl
    · rw [if_neg hc] at h2
      simp [hshr, hops, h1, h2, h3, h4] <;> (try split) <;> (try split) <;> (try split) <;> rfl

/-- Outside PE's pad region, the outgoing area a call reads agrees between the shadow and R
after the scopes (the row's stack reads cover it, `FactsAgree`). -/
theorem call_stack_agree (C : Cert S) {s s1 : R.RState} {P : Int → Prop} (h : StepPre S C s P)
    {op : Reduced.Opcode} {f : Full.Opcode} {dd : BitVec 32} {fo : Opnd Nat} {k : BitVec 64}
    {ws : List (BitVec 32)}
    (hi : S.c.d.insns[s.pc]? = some (.native op [.slot dd, fo, .imm k, .words ws]))
    (hf : op.full = some f) (hsc : f.info.shape = .call)
    (hs1 : (S.c.scopesAt s.pc).foldlM R.applyScope s = .ok s1)
    (hca : Frame.callArgs [.slot dd, fo, .imm k, .words ws] = ws) :
    (erase s1 P).st.readFrame (-(S.c.d.frameSize : Int)) (S.c.stackSize (erase s1 P).pc) =
      s1.st.readFrame (-(S.c.d.frameSize : Int)) (S.c.stackSize s1.pc) := by
  have hpc : s1.pc = s.pc := (Ryo.Proofs.Scope.scopes_keeps _ hs1).pc
  have hlt := h.lt
  have hshr : op.info.shape = .call := (reduced_shape hf).trans hsc
  have hni : (op.full.bind Asm.classOf).isSome = false := by
    cases hb : (op.full.bind Asm.classOf).isSome
    · rfl
    · exact (h.notInline ⟨op, _, hi, hb⟩).elim
  obtain ⟨-, -, -, -, hends⟩ := flowOf_call_row C.hfl hi hni hshr
  have hk : s.pc < S.c.d.insns.size := hlt
  have hik : S.c.d.insns[s.pc]! = .native op [.slot dd, fo, .imm k, .words ws] := by
    rw [getElem!_pos S.c.d.insns s.pc hk]
    rw [Array.getElem?_eq_getElem hk] at hi
    exact Option.some.inj hi
  obtain ⟨e, he, eb, hstk⟩ := flowOf_stack_row C.hfl hk
  rw [hik] at he
  simp only [Frame.effects, hni, Bool.false_eq_true, ↓reduceIte, pure, Except.pure,
    Except.ok.injEq] at he
  subst he
  have hRA := native_call_readsAll hf hsc dd fo k ws S.c.mode.pe
    (Frame.Flow.lendsOf (Frame.scopesAt S.c.d) s.pc) (C.facts.islandTemplate s.pc)
  have hc1 : (op.info.shape == .call) = true := by rw [hshr]; rfl
  have hF := h.hyps.frameBounds.F_le
  have hb32 : (BitVec.ofInt 32 (-(S.c.d.frameSize : Int))).toInt = -(S.c.d.frameSize : Int) := by
    rw [BitVec.toInt_ofInt]
    exact Int.bmod_eq_of_le (by omega) (by omega)
  show (eraseSt P s1.st).readFrame _ (S.c.stackSize s1.pc) = _
  rw [hpc]
  apply readFrame_erase_of
  intro o h1 h2 hpo _
  obtain ⟨hif, -, -, -⟩ := h.patch o hpo
  obtain ⟨hf1, hf2⟩ := hif
  try rw [hb32] at h1
  try rw [hb32] at h2
  cases hmay : Frame.mayHaveStackArgs S.c.mode.pe ws with
  | false =>
    cases hsa : C.facts.stackArgs s.pc with
    | none =>
      have h0 := h.facts.noStack s.pc op _ hi hsa (by rw [hca]; exact hmay)
      rw [h0] at h2
      omega
    | some m =>
      -- a `byval` call: the row reads its `stackArgs` bytes all the same
      have hm := h.facts.stack s.pc m hsa
      have hsb : (Frame.Ranges.bits C.fl.stack[s.pc]!).testBit (bit S o) = true := by
        rw [hstk]
        simp only [Frame.Flow.rowOf, Frame.Flow.callInfo, hik, hc1, hRA, hmay, hsa,
          Bool.not_false, eq_self_iff_true, ↓reduceIte]
        rw [testBit_rangesBits]
        simp only [List.any_cons, List.any_nil, Bool.or_false, Bool.and_eq_true, Frame.range]
        refine ⟨decide_eq_true ?_, decide_eq_true ?_⟩ <;> simp only [bit, hb32] <;>
          (try rw [BitVec.toInt_ofInt]) <;> omega
      exact read_uninit C h hs1 hends hpo (gen_of_stack_bit hsb)
  | true =>
    have hsb : (Frame.Ranges.bits C.fl.stack[s.pc]!).testBit (bit S o) = true := by
      rw [hstk]
      simp only [Frame.Flow.rowOf, Frame.Flow.callInfo, hik, hc1, hRA, hmay, Bool.not_true,
        Bool.false_eq_true, ↓reduceIte]
      cases hsa : C.facts.stackArgs s.pc with
      | none =>
        simp only [hsa]
        rw [testBit_rangesBits]
        simp only [List.any_cons, List.any_nil, Bool.or_false, Bool.and_eq_true]
        refine ⟨decide_eq_true ?_, decide_eq_true ?_⟩ <;> simp only [bit] <;> omega
      | some m =>
        have hm := h.facts.stack s.pc m hsa
        simp only [hsa]
        rw [testBit_rangesBits]
        simp only [List.any_cons, List.any_nil, Bool.or_false, Bool.and_eq_true, Frame.range]
        refine ⟨decide_eq_true ?_, decide_eq_true ?_⟩ <;> simp only [bit, hb32] <;>
          (try rw [BitVec.toInt_ofInt]) <;> omega
    exact read_uninit C h hs1 hends hpo (gen_of_stack_bit hsb)

/-- A call from the shadow fails as from `s` (its reads agree). -/
theorem rsafe_call (C : Cert S) {s s1 : R.RState} {P : Int → Prop} (h : StepPre S C s P)
    {op : Reduced.Opcode} {f : Full.Opcode} {dd : BitVec 32} {fo : Opnd Nat} {k : BitVec 64}
    {ws : List (BitVec 32)}
    (hi : S.c.d.insns[s.pc]? = some (.native op [.slot dd, fo, .imm k, .words ws]))
    (hf : op.full = some f) (hsc : f.info.shape = .call)
    (hs1 : (S.c.scopesAt s.pc).foldlM R.applyScope s = .ok s1)
    (hsce : (S.c.scopesAt (erase s P).pc).foldlM R.applyScope (erase s P) = .ok (erase s1 P))
    {ch : OpSem.Choice} {e : OpSem.Stop} (he : R.step S.c (erase s P) ch = .error e) :
    R.step S.c s ch = .error e := by
  have hi' : S.c.d.insns[(erase s P).pc]? = some (.native op [.slot dd, fo, .imm k, .words ws]) :=
    hi
  have hshr : op.info.shape = .call := (reduced_shape hf).trans hsc
  have hni : (op.full.bind Asm.classOf).isSome = false := by
    cases hb : (op.full.bind Asm.classOf).isSome
    · rfl
    · exact (h.notInline ⟨op, _, hi, hb⟩).elim
  obtain ⟨eb, -, -, hsub, hends⟩ := flowOf_call_row C.hfl hi hni hshr
  unfold R.step at he ⊢
  simp only [hi', bind, Except.bind, hsce, hf, hsc] at he
  simp only [hi, bind, Except.bind, hs1, hf, hsc]
  cases hp : R.retRegs k.toNat false with
  | error e' =>
    simp only [hp] at he ⊢
    exact he
  | ok parts =>
    simp only [hp] at he ⊢
    obtain ⟨pa, pb, hrp, -⟩ := retRegs_cover hp
    have hk32 : k.toNat < 2 ^ 32 := retParts_lt hrp
    obtain ⟨A, hops, -, hAp⟩ := native_call_opnds hf hsc dd fo k ws S.c.mode.pe
      (Frame.Flow.lendsOf (Frame.scopesAt S.c.d) s.pc) (C.facts.islandTemplate s.pc) hk32 hrp
    have hcov : ∀ (x : BitVec 32 × Frame.Access) (m : Nat),
        x ∈ (Frame.native op [.slot dd, fo, .imm k, .words ws] S.c.mode.pe
          (Frame.Flow.lendsOf (Frame.scopesAt S.c.d) s.pc) (C.facts.islandTemplate s.pc)).opnds →
        x.2 = .read m → (eraseSt P s1.st).readFrame x.1.toInt m = s1.st.readFrame x.1.toInt m := by
      intro x m hx hm
      refine call_read_agree C h hs1 hends hsub (fun i h1 h2 => ?_)
      have hiF : i < S.c.d.frameSize := by simp only [Frame.range] at h2; omega
      exact opndRanges_read_cover _ _ _ hiF _ ([], []) (.inr ⟨x, hx, m, hm, h1, h2⟩)
    have hcalE : R.callee (erase s1 P).st f fo = R.callee s1.st f fo :=
      callee_erase_eq (fun p hfo hcp => hcov (p, .read 8) 8
        (by rw [hops]; exact List.mem_append_left _ (List.mem_append_left _ (hAp hcp p hfo))) rfl)
    have hargE : R.argRegs (erase s1 P).st ws = R.argRegs s1.st ws :=
      argRegs_erase_eq ws (fun x hx m hm => hcov x m
        (by rw [hops]; exact List.mem_append_right _ hx) hm)
    rw [hcalE, hargE] at he
    cases hc : R.callee s1.st f fo with
    | error e' =>
      simp only [hc] at he ⊢
      exact he
    | ok cal =>
      simp only [hc] at he ⊢
      have hca : Frame.callArgs [.slot dd, fo, .imm k, .words ws] = ws := by
        cases fo with
        | words ws0 =>
          simp [R.callee, OpSem.illFormed, throw, throwThe, MonadExceptOf.throw] at hc
        | _ => simp [Frame.callArgs]
      cases ha : R.argRegs s1.st ws with
      | error e' =>
        simp only [ha] at he ⊢
        exact he
      | ok regs =>
        simp only [ha] at he ⊢
        by_cases hreg : S.c.inRegion s1.pc = true
        · have hreg' : S.c.inRegion (erase s1 P).pc = true := hreg
          simp only [hreg, hreg', ↓reduceIte, pure, Except.pure] at he ⊢
          split at he
          · rename_i n dst h1 h2
            have h1' : S.c.sretSize s1.pc = some n := h1
            cases hw : (erase s1 P).st.writeFrame dst.toInt (List.replicate n .uninit) with
            | error e' =>
              rw [hw] at he
              have hw2 : s1.st.writeFrame dst.toInt (List.replicate n .uninit) = .error e' :=
                writeFrame_err hw rfl rfl
              simp only [h1', h2, hw2]
              exact he
            | ok st' =>
              rw [hw] at he
              cases he
          · cases he
        · have hreg2 : S.c.inRegion s1.pc = false := by simpa using hreg
          have hreg' : S.c.inRegion (erase s1 P).pc = false := hreg2
          simp only [hreg2, hreg', Bool.false_eq_true, ↓reduceIte] at he ⊢
          rw [call_stack_agree C h hi hf hsc hs1 hca] at he
          cases hfa : R.frameAddr s1.fp (-(S.c.d.frameSize : Int)) with
          | error e' =>
            have hfa' : R.frameAddr (erase s1 P).fp (-(S.c.d.frameSize : Int)) = .error e' := hfa
            rw [hfa'] at he
            simp only [hfa]
            exact he
          | ok sp =>
            have hfa' : R.frameAddr (erase s1 P).fp (-(S.c.d.frameSize : Int)) = .ok sp := hfa
            rw [hfa'] at he
            simp only [hfa]
            cases hrd : s1.st.readFrame (-(S.c.d.frameSize : Int)) (S.c.stackSize s1.pc) with
            | error e' =>
              rw [hrd] at he
              exact he
            | ok stack =>
              rw [hrd] at he
              try dsimp only at he ⊢
              split at he
              · rename_i n dst h1 h2
                have h1' : S.c.sretSize s1.pc = some n := h1
                cases hw : (erase s1 P).st.writeFrame dst.toInt (List.replicate n .uninit) with
                | error e' =>
                  rw [hw] at he
                  have hw2 : s1.st.writeFrame dst.toInt (List.replicate n .uninit) = .error e' :=
                    writeFrame_err hw rfl rfl
                  simp only [h1', h2, hw2]
                  exact he
                | ok st' =>
                  rw [hw] at he
                  cases he
              · cases he

/-! ### Safety of the shadow's step: `opSem` instructions (T3b) -/

set_option maxRecDepth 8000 in
/-- `opSem` from the shadow fails as from the state when the bytes of `P` it reads are
`Uninit` (without a footprint it fails before reading). -/
theorem opSem_err_erase {op : Full.Opcode} {ops : OpSem.Operands} {st : OpSem.State}
    {P : Int → Prop} {ch : OpSem.Choice} {e : OpSem.Stop}
    (hrd : ∀ fp, OpSem.footprint op = some fp → ∀ o,
      (∃ rg ∈ fp.readRanges (OpSem.opndVal op.info ops), OpSem.inRange o rg = true) →
      P o → st.frame o = .uninit)
    (h : OpSem.opSem op ops (eraseSt P st) ch = .error e) : OpSem.opSem op ops st ch = .error e := by
  cases hfp : OpSem.footprint op with
  | none =>
    unfold OpSem.opSem at h ⊢
    cases hp : OpSem.prepare op ops with
    | error e' =>
      try rw [hp] at h
      try rw [hp]
      exact h
    | ok x =>
      obtain ⟨hi, fp', val⟩ := x
      rw [(OpSem.prepare_ok hp).1] at hfp
      cases hfp
  | some fp =>
    have hs : (eraseSt P st).SameButFrame st := ⟨rfl, rfl, rfl, rfl, rfl⟩
    have hf : ∀ o, (∃ rg ∈ fp.readRanges (OpSem.opndVal op.info ops), OpSem.inRange o rg = true) →
        (eraseSt P st).frame o = st.frame o := by
      intro o ho
      by_cases hp : P o
      · simp only [eraseSt, hp, ↓reduceIte]
        exact (hrd fp hfp o ho hp).symm
      · simp only [eraseSt, hp, ↓reduceIte]
    have hrr := OpSem.opSem_reads_footprint (op := op) (ops := ops) (st1 := eraseSt P st)
      (st2 := st) (ch := ch) (fp := fp) hfp hs hf
    rw [h] at hrr
    cases h2 : OpSem.opSem op ops st ch with
    | error e2 =>
      rw [h2] at hrr
      simp only [OpSem.ResultRel] at hrr
      rw [hrr]
    | ok r2 =>
      rw [h2] at hrr
      simp only [OpSem.ResultRel] at hrr

theorem clearHome_err {pe : Bool} {n : Nat} {off : Int} {a b : OpSem.State} {e : OpSem.Stop}
    (h : R.clearHome pe n off a = .error e) (he : a.escaped = b.escaped) (hm : a.mem = b.mem) :
    R.clearHome pe n off b = .error e := by
  unfold R.clearHome at h ⊢
  split at h
  · rename_i hpe
    rw [if_pos hpe]
    exact writeFrame_err h he hm
  · cases h

set_option maxRecDepth 8000 in
/-- An `opSem` instruction (handler or native, not `resume`) from the shadow fails as from the
state, when the bytes of `P` its footprint reads are `Uninit`. -/
theorem stepView_err_erase {c : R.Code} {u : R.RState} {P : Int → Prop} {i : Insn}
    {ch : OpSem.Choice} {e : OpSem.Stop}
    (hres : ∀ v, R.view c.mode c.ρ i = some v → v.op ≠ .resume)
    (hrd : ∀ v, R.view c.mode c.ρ i = some v → ∀ fp, OpSem.footprint v.op = some fp → ∀ o,
      (∃ rg ∈ fp.readRanges (OpSem.opndVal v.op.info v.ops), OpSem.inRange o rg = true) →
      P o → u.st.frame o = .uninit)
    (h : R.stepView c (erase u P) i ch = .error e) : R.stepView c u i ch = .error e := by
  unfold R.stepView at h ⊢
  cases hv : R.view c.mode c.ρ i with
  | none =>
    simp only [hv] at h ⊢
    exact h
  | some v =>
    simp only [hv] at h ⊢
    cases hct : v.ctl with
    | none =>
      simp only [hct] at h ⊢
      exact h
    | some t =>
      have h1 : (v.op == .resume) = false := by simpa using hres v hv
      simp only [hct, h1, Bool.false_eq_true, ↓reduceIte] at h ⊢
      by_cases hu : (v.op == .unreachable) = true
      · simp only [hu, ↓reduceIte] at h ⊢
        exact h
      simp only [hu, Bool.false_eq_true, ↓reduceIte, bind, Except.bind] at h ⊢
      cases ho : OpSem.opSem v.op v.ops (erase u P).st ch with
      | error e' =>
        have ho' : OpSem.opSem v.op v.ops (eraseSt P u.st) ch = .error e' := ho
        rw [ho] at h
        rw [opSem_err_erase (hrd v hv) ho']
        exact h
      | ok r =>
        rw [ho] at h
        have ho' : OpSem.opSem v.op v.ops (eraseSt P u.st) ch = .ok r := ho
        obtain ⟨fp, hfp⟩ := opSem_fp ho'
        obtain ⟨r2, ho2, hc12, hfr⟩ := opSem_erase hfp (hrd v hv fp hfp) ho'
        rw [ho2]
        obtain ⟨ctl, st⟩ := r
        obtain ⟨ctl2, st2⟩ := r2
        simp only at hc12
        subst hc12
        try dsimp only at h ⊢
        cases i with
        | handler hh args t' =>
          try dsimp only at h ⊢
          cases hch : R.clearHome c.mode.pe args.length (-(c.d.frameSize : Int)) st with
          | error e' =>
            rw [hch] at h
            rw [clearHome_err hch hfr.1.1 hfr.1.2.1]
            exact h
          | ok st' =>
            rw [hch] at h
            obtain ⟨st2', hch2, -⟩ := clearHome_rel hfr hch
            rw [hch2]
            try dsimp only at h ⊢
            cases hs : t.succ u.pc ctl with
            | none =>
              have hs' : t.succ (erase u P).pc ctl = none := hs
              simp only [hs'] at h
              simp only [hs]
              exact h
            | some pc =>
              have hs' : t.succ (erase u P).pc ctl = some pc := hs
              simp only [hs'] at h
              cases h
        | native op ops =>
          try dsimp only at h ⊢
          cases hs : t.succ u.pc ctl with
          | none =>
            have hs' : t.succ (erase u P).pc ctl = none := hs
            simp only [hs'] at h
            simp only [hs]
            exact h
          | some pc =>
            have hs' : t.succ (erase u P).pc ctl = some pc := hs
            simp only [hs'] at h
            cases h

/-- T3b: the shadow's step is safe (its errors are `s`'s, its queries equal `s`'s). -/
theorem rsafe_erase (C : Cert S) {s : R.RState} {P : Int → Prop} (h : StepPre S C s P) :
    RSafe S.Safe S.c (erase s P) := by
  have hlt : s.pc < S.c.d.insns.size := h.lt
  have hi0 : S.c.d.insns[s.pc]? = some S.c.d.insns[s.pc] := Array.getElem?_eq_getElem hlt
  refine ⟨fun ch e he => ?_, fun ch q s1 hq => ?_⟩
  · cases hsc : (S.c.scopesAt s.pc).foldlM R.applyScope (erase s P) with
    | error e' =>
      -- the scopes fail as from `s`
      have he' : R.step S.c (erase s P) ch = .error e' := step_scopes_err (u := erase s P) hi0 hsc
      rw [he'] at he
      cases he
      exact h.safe.1 ch _ (step_scopes_err hi0 (scopes_erase_err C h hsc))
    | ok t1 =>
      obtain ⟨s1, hs1, rfl⟩ := scopes_erase_eq C h hsc
      have hsce : (S.c.scopesAt (erase s P).pc).foldlM R.applyScope (erase s P) =
          .ok (erase s1 P) := hsc
      have hpc : s1.pc = s.pc := (Ryo.Proofs.Scope.scopes_keeps _ hs1).pc
      refine h.safe.1 ch e ?_
      cases hk : S.c.d.insns[s.pc] with
      | handler hh args t =>
        have hi : S.c.d.insns[s.pc]? = some (.handler hh args t) := by simp only [hi0, hk]
        have hi' : S.c.d.insns[(erase s P).pc]? = some (.handler hh args t) := hi
        by_cases hun : hh = .unreachable
        · subst hun
          have hv : R.view S.c.mode S.c.ρ (.handler .unreachable args t) = none := by
            cases hv : R.view S.c.mode S.c.ρ (.handler .unreachable args t) with
            | none => rfl
            | some v =>
              have := view_handler_has hv
              rw [Ryo.Proofs.DecodeLink.noHandler.2.2.1] at this
              cases this
          rw [Ryo.Proofs.Shapes.step_handler hi' hsce] at he
          rw [Ryo.Proofs.Shapes.step_handler hi hs1, stepView_none_eq hv (u := s1) (u' := erase s1 P) rfl]
          exact he
        by_cases hres : hh = .resume
        · subst hres
          rw [Ryo.Proofs.Shapes.step_handler hi' hsce] at he
          rw [Ryo.Proofs.Shapes.step_handler hi hs1]
          refine stepView_resume_err (u := erase s1 P) rfl (fun v x hv hx => ?_) he
          obtain ⟨e', eb, he', -, -, hsub, hends⟩ := flowOf_handler_row C.hfl hi
          have hu := view_handler_unpack hv
          obtain ⟨-, -, hRes⟩ := handlerVals_agree S.c.d.frameSize eb hu he'
          apply readFrame_erase_of
          intro o h1 h2 hpo _
          obtain ⟨hif, -, -, -⟩ := h.patch o hpo
          exact read_uninit C h hs1 hends hpo
            (gen_of_operand_mem hsub (hRes rfl x hx o hif.1 hif.2 h1 (by omega)))
        rw [Ryo.Proofs.Shapes.step_handler hi' hsce] at he
        rw [Ryo.Proofs.Shapes.step_handler hi hs1]
        refine stepView_err_erase (fun v hv => by rw [(view_handler hv).1]; exact hres)
          (fun v hv fp hfp o hread hpo => ?_) he
        obtain ⟨e', eb, he', -, -, hsub, hends⟩ := flowOf_handler_row C.hfl hi
        have hu := view_handler_unpack hv
        obtain ⟨hR, -, -⟩ := handlerVals_agree S.c.d.frameSize eb hu he'
        obtain ⟨hif, -, -, -⟩ := h.patch o hpo
        have hop := (view_handler hv).1
        rw [hop] at hfp hread
        exact read_uninit C h hs1 hends hpo
          (gen_of_operand_mem hsub (hR fp hfp o hif.1 hif.2 hread))
      | native op ops =>
        have hi : S.c.d.insns[s.pc]? = some (.native op ops) := by simp only [hi0, hk]
        have hi' : S.c.d.insns[(erase s P).pc]? = some (.native op ops) := hi
        cases hf : op.full with
        | none =>
          unfold R.step at he ⊢
          simp only [hi', bind, Except.bind, hsce, hf] at he
          simp only [hi, bind, Except.bind, hs1, hf]
          exact he
        | some g =>
          by_cases hbad : (g.info.shape = .jmp ∧ ∀ tg, ops ≠ [.target tg]) ∨
              (g.info.shape = .arg ∧ ∀ d r, ops ≠ [.slot d, .imm r]) ∨
              (g.info.shape = .ret ∧ ∀ src k, ops ≠ [.slot src, .imm k]) ∨
              (g.info.shape = .tailCall ∧ ∀ fo ws, ops ≠ [fo, .words ws]) ∨
              (g.info.shape = .island ∧ ∀ isl ws, ops ≠ [.sym isl, .words ws]) ∨
              (g.info.shape = .call ∧ ∀ d fo k ws, ops ≠ [.slot d, fo, .imm k, .words ws])
          · rw [step_shape_bad hi' hf hsce hbad] at he
            rw [step_shape_bad hi hf hs1 hbad]
            exact he
          by_cases hsj : g.info.shape = .jmp
          · obtain ⟨tg, rfl⟩ : ∃ tg, ops = [.target tg] :=
              Classical.byContradiction fun hne =>
                hbad (.inl ⟨hsj, fun tg htg => hne ⟨tg, htg⟩⟩)
            rw [step_jmp_of (s := erase s P) hi hf hsj hsce] at he
            cases he
          by_cases hsa : g.info.shape = .arg
          · obtain ⟨d, r, rfl⟩ : ∃ d r, ops = [.slot d, .imm r] :=
              Classical.byContradiction fun hne =>
                hbad (.inr (.inl ⟨hsa, fun d r hdr => hne ⟨d, r, hdr⟩⟩))
            exact step_arg_err hi hf hsa hs1 hsce he
          by_cases hsr : g.info.shape = .ret
          · obtain ⟨src, kk, rfl⟩ : ∃ src k, ops = [.slot src, .imm k] :=
              Classical.byContradiction fun hne =>
                hbad (.inr (.inr (.inl ⟨hsr, fun src k hsk => hne ⟨src, k, hsk⟩⟩)))
            exact rsafe_ret C h hi hf hsr hs1 hsce he
          by_cases hun : g = .unreachable
          · have hos : R.opShape g = true := by subst hun; decide +kernel
            rw [step_native_of (s := erase s P) hi hf hos hsce] at he
            rw [step_native_of hi hf hos hs1,
              stepView_unreach_eq (u := s1) (u' := erase s1 P) hf hos hun rfl]
            exact he
          by_cases hst : g.info.shape = .tailCall
          · obtain ⟨fo, ws, rfl⟩ : ∃ fo ws, ops = [fo, .words ws] :=
              Classical.byContradiction fun hne =>
                hbad (.inr (.inr (.inr (.inl ⟨hst, fun fo ws hfw => hne ⟨fo, ws, hfw⟩⟩))))
            exact rsafe_tail C h hi hf hst hs1 hsce he
          by_cases hsi : g.info.shape = .island
          · obtain ⟨isl, ws, rfl⟩ : ∃ isl ws, ops = [.sym isl, .words ws] :=
              Classical.byContradiction fun hne =>
                hbad (.inr (.inr (.inr (.inr (.inl ⟨hsi, fun isl ws hiw => hne ⟨isl, ws, hiw⟩⟩)))))
            rw [step_island_of (s := erase s P) hi hf hsi hsce] at he
            cases he
          by_cases hsc : g.info.shape = .call
          · obtain ⟨dd, fo, kk, ws, rfl⟩ : ∃ d fo k ws, ops = [.slot d, fo, .imm k, .words ws] :=
              Classical.byContradiction fun hne =>
                hbad (.inr (.inr (.inr (.inr (.inr ⟨hsc, fun d fo k ws hx =>
                  hne ⟨d, fo, k, ws, hx⟩⟩)))))
            exact rsafe_call C h hi hf hsc hs1 hsce he
          have hos := opShape_of_ne hsj hsa hsi ⟨hsc, hst, hsr⟩
          rw [step_native_of (s := erase s P) hi hf hos hsce] at he
          rw [step_native_of hi hf hos hs1]
          refine stepView_err_erase (fun v hv => ?_) (fun v hv fp hfp o hread hpo => ?_) he
          · obtain ⟨vals, t, -, -, rfl⟩ := Ryo.Proofs.Step.view_native hf hos hv
            exact reduced_ne_resume hf
          · obtain ⟨vals, t, hnv, -, rfl⟩ := Ryo.Proofs.Step.view_native hf hos hv
            have hshr := reduced_shape hf
            have hc1 : (op.info.shape == .call) = false := by
              rw [hshr]; exact beq_eq_false_iff_ne.2 hsc
            have hc2 : (op.info.shape == .tailCall) = false := by
              rw [hshr]; exact beq_eq_false_iff_ne.2 hst
            have hni : (op.full.bind Asm.classOf).isSome = false := by
              cases hb : (op.full.bind Asm.classOf).isSome
              · rfl
              · exact (h.notInline ⟨op, _, hi, hb⟩).elim
            obtain ⟨eb, -, -, hsub, hends⟩ := flowOf_native_row C.hfl hi hni hc1 hc2
            obtain ⟨hR, -⟩ := nativeVals_agree S.c.mode.pe
              (Frame.Flow.lendsOf (Frame.scopesAt S.c.d) s.pc) (C.facts.islandTemplate s.pc)
              S.c.d.frameSize eb hf hni hnv
            obtain ⟨hif, -, -, -⟩ := h.patch o hpo
            exact read_uninit C h hs1 hends hpo
              (gen_of_operand_mem hsub (hR fp hfp o hif.1 hif.2 hread))
  · -- queries: only calls and islands ask; an island's query is the state's
    cases hsc : (S.c.scopesAt s.pc).foldlM R.applyScope (erase s P) with
    | error e' =>
      rw [step_scopes_err (u := erase s P) hi0 hsc] at hq
      cases hq
    | ok t1 =>
      obtain ⟨v1, hs1, rfl⟩ := scopes_erase_eq C h hsc
      have hsce : (S.c.scopesAt (erase s P).pc).foldlM R.applyScope (erase s P) =
          .ok (erase v1 P) := hsc
      cases hk : S.c.d.insns[s.pc] with
      | handler hh args t =>
        exfalso
        have hi : S.c.d.insns[s.pc]? = some (.handler hh args t) := by simp only [hi0, hk]
        have hi' : S.c.d.insns[(erase s P).pc]? = some (.handler hh args t) := hi
        rw [Ryo.Proofs.Shapes.step_handler hi' hsce] at hq
        by_cases hres : hh = .resume
        · subst hres
          obtain ⟨_, _, _, _, _, _, _, _, hun⟩ := stepView_resume_ok hq
          unfold R.unwindAt at hun
          split at hun <;> simp [OpSem.ub, throw, throwThe, MonadExceptOf.throw, pure,
            Except.pure] at hun
        by_cases hun : hh = .unreachable
        · subst hun
          unfold R.stepView at hq
          cases hv : R.view S.c.mode S.c.ρ (.handler .unreachable args t) with
          | none =>
            rw [hv] at hq
            simp [OpSem.illFormed, throw, throwThe, MonadExceptOf.throw] at hq
          | some v =>
            have := view_handler_has hv
            rw [Ryo.Proofs.DecodeLink.noHandler.2.2.1] at this
            cases this
        · obtain ⟨_, _, _, _, _, _, _, _, _, _, hc⟩ := stepView_handler_ok hres hun hq
          cases hc
      | native op ops =>
        have hi : S.c.d.insns[s.pc]? = some (.native op ops) := by simp only [hi0, hk]
        have hi' : S.c.d.insns[(erase s P).pc]? = some (.native op ops) := hi
        cases hf : op.full with
        | none =>
          exfalso
          unfold R.step at hq
          simp only [hi', bind, Except.bind, hsce] at hq
          simp [hf, OpSem.illFormed, throw, throwThe, MonadExceptOf.throw] at hq
        | some g =>
          obtain ⟨hcs, hts, hrs⟩ := step_call_shape hi' hf hq
          by_cases hsc : g.info.shape = .call
          · obtain ⟨dd, fo, kk, ws, rfl⟩ := hcs hsc
            obtain ⟨u1, parts, cal, regs, sp, stack, stS, hscS, hp, hcal, hargs, hR1, hR2, hsret,
              hqe⟩ := step_call_ok hi' hf hsc hq
            rw [hsce] at hscS
            cases hscS
            cases hqe
            have hshr : op.info.shape = .call := (reduced_shape hf).trans hsc
            have hni : (op.full.bind Asm.classOf).isSome = false := by
              cases hb : (op.full.bind Asm.classOf).isSome
              · rfl
              · exact (h.notInline ⟨op, _, hi, hb⟩).elim
            obtain ⟨eb, -, -, hsub, hends⟩ := flowOf_call_row C.hfl hi hni hshr
            obtain ⟨pa, pb, hrp, -⟩ := retRegs_cover hp
            have hk32 : kk.toNat < 2 ^ 32 := retParts_lt hrp
            obtain ⟨A, hops, -, hAp⟩ := native_call_opnds hf hsc dd fo kk ws S.c.mode.pe
              (Frame.Flow.lendsOf (Frame.scopesAt S.c.d) s.pc) (C.facts.islandTemplate s.pc)
              hk32 hrp
            have hcov : ∀ (x : BitVec 32 × Frame.Access) (m : Nat),
                x ∈ (Frame.native op [.slot dd, fo, .imm kk, .words ws] S.c.mode.pe
                  (Frame.Flow.lendsOf (Frame.scopesAt S.c.d) s.pc)
                  (C.facts.islandTemplate s.pc)).opnds →
                x.2 = .read m →
                  (eraseSt P v1.st).readFrame x.1.toInt m = v1.st.readFrame x.1.toInt m := by
              intro x m hx hm
              refine call_read_agree C h hs1 hends hsub (fun i h1 h2 => ?_)
              have hiF : i < S.c.d.frameSize := by simp only [Frame.range] at h2; omega
              exact opndRanges_read_cover _ _ _ hiF _ ([], []) (.inr ⟨x, hx, m, hm, h1, h2⟩)
            have hcalR : R.callee v1.st g fo = .ok cal := by
              refine callee_erase (fun p hfo hcp => ?_) hcal
              refine hcov (p, .read 8) 8 ?_ rfl
              rw [hops]
              exact List.mem_append_left _ (List.mem_append_left _ (hAp hcp p hfo))
            have hargsR : R.argRegs v1.st ws = .ok regs := by
              refine argRegs_erase ws (fun x hx m hm => hcov x m ?_ hm) hargs
              rw [hops]
              exact List.mem_append_right _ hx
            have hca : Frame.callArgs [.slot dd, fo, .imm kk, .words ws] = ws := by
              cases fo with
              | words ws0 =>
                simp [R.callee, OpSem.illFormed, throw, throwThe, MonadExceptOf.throw] at hcalR
              | _ => simp [Frame.callArgs]
            have hR2' : S.c.inRegion v1.pc = false →
                R.frameAddr v1.fp (-(S.c.d.frameSize : Int)) = .ok sp ∧
                v1.st.readFrame (-(S.c.d.frameSize : Int)) (S.c.stackSize v1.pc) = .ok stack :=
              fun hr => ⟨(hR2 hr).1, by
                rw [← call_stack_agree C h hi hf hsc hs1 hca]; exact (hR2 hr).2⟩
            unfold SretW at hsret
            obtain ⟨st2, hsretR, rfl⟩ : ∃ st2, SretW S.c v1.pc ws v1.st st2 ∧ stS = eraseSt P st2 := by
              rcases hsret with ⟨n, dst, hn, hdst, hw⟩ | ⟨hno, heq⟩
              · obtain ⟨st2, hw2, rfl⟩ := writeFrame_erase hw
                exact ⟨st2, Or.inl ⟨n, dst, hn, hdst, hw2⟩, rfl⟩
              · exact ⟨v1.st, Or.inr ⟨hno, rfl⟩, heq⟩
            have hRstep := step_call_of (ch := ch) hi hf hsc hs1 hp hcalR hargsR hR1 hR2' hsretR
            exact h.safe.2 ch _ _ hRstep
          by_cases hsi : g.info.shape = .island
          · obtain ⟨-, -, his⟩ := step_native_shape hi' hf hq
            obtain ⟨isl, ws, rfl⟩ := his hsi
            obtain ⟨t1', hsc', hqe⟩ := step_island_ok hi' hf hsi hq
            rw [hsce] at hsc'
            cases hsc'
            cases hqe
            have hR := step_island_of (s1 := v1) (ch := ch) hi hf hsi hs1
            exact h.safe.2 ch _ _ hR
          exfalso
          by_cases hst : g.info.shape = .tailCall
          · obtain ⟨fo, ws, rfl⟩ := hts hst
            obtain ⟨_, _, _, _, _, _, _, _, hc⟩ := step_tailCall_done hi' hf hst hq
            cases hc
          by_cases hsr : g.info.shape = .ret
          · obtain ⟨src, kk, rfl⟩ := hrs hsr
            obtain ⟨_, _, _, _, _, _, _, _, hc⟩ := Ryo.Proofs.ArgRet.step_ret hi' hf hsr hq
            cases hc
          obtain ⟨_, hc⟩ := step_plain_step hi' hf ⟨hsc, hst, hsr⟩ hsi hq
          cases hc

end Ryo.Proofs.DeadStore
