/-
Ryo.Proofs.DeadStore.Sim — `decode_sound` on `DInv` (design T6, T7; statements from T0).

`decode_sound_d` is `decode_sound` (`Ryo/Proofs/DecodeSound.lean`) with the boundary relation
`DInv S oc` instead of `BInv S`, so that it needs no `Hyps.deadStore`: its proof must not use
that field (T6 then deletes `DeadStoreSim`, moves `FootprintExact` into `Hyps` and restates
`decode_sound`, `_of_ok`, `_of_checked` by these).

- `DNext`, `DBodySim`, `DInsnSimAt`: `SNext`, `BodySim`, `InsnSimAt` on the ghost.
- T6: `bodySim_noninline_empty` (the non-inline bodies hold with the empty cache: they don't
  read it), `dbodySim_noninline` (erase, `BodySim`, T3, re-ghost), `dbodySim_inline` (T4 with
  `inline_step_cached`'s run, for every inline read, dropped store or not, since `P` may be
  nonempty), `dinsn_main` (padding and counter check on `x`, ghost alongside), `dinsn_empty`
  (`Iter.empty`, by `dbodySim_inline_at` at `S.start k`), `dinsn_oob`, `decode_sound_d`.
- T7: `decodeChecked_dropped`, `mem_dropped_of_proto`, `certOpt` and `certOpt_none`.
-/
import Ryo.Proofs.DecodeSound
import Ryo.Proofs.DeadStore.Rel
import Ryo.Proofs.DeadStore.RStep
import Ryo.Proofs.DeadStore.Items
import Ryo.Proofs.DeadStore.Covered
import Ryo.Proofs.DeadStore.KeptRead
import Ryo.Proofs.DeadStore.PtrLive
import Ryo.Proofs.DeadStore.DropForm

/-! ### `dinline_pre_apart`'s pieces (DS-T9): the order of an emitted sequence's items -/

namespace Ryo.Proofs.CacheStep

open Ryo.Spec Ryo.Vm Ryo.Vm.OpSem Ryo.X86 Ryo.Vm.Asm Ryo.Proofs.Inline Ryo.Proofs.Scope
  Ryo.Proofs.Step Ryo.Proofs.RegCache

/-- `y` comes before `x` in `l`. -/
def Before (l : List Item) (y x : Item) : Prop := ∃ pre post, l = pre ++ x :: post ∧ y ∈ pre

theorem before_cons {a y x : Item} {l : List Item} (h : Before (a :: l) y x) :
    (y = a ∧ x ∈ l) ∨ Before l y x := by
  obtain ⟨pre, post, e, hy⟩ := h
  cases pre with
  | nil => cases hy
  | cons p pre =>
    simp only [List.cons_append, List.cons.injEq] at e
    obtain ⟨rfl, rfl⟩ := e
    rcases List.mem_cons.1 hy with rfl | hy'
    · exact .inl ⟨rfl, List.mem_append_right _ (List.mem_cons.2 (.inl rfl))⟩
    · exact .inr ⟨pre, post, rfl, hy'⟩

theorem before_nil {y x : Item} (h : Before [] y x) : False := by
  obtain ⟨pre, post, e, -⟩ := h
  cases pre <;> simp at e

theorem before_cons_of {a y x : Item} {l : List Item} (h : Before l y x) : Before (a :: l) y x := by
  obtain ⟨pre, post, e, hy⟩ := h
  subst e
  exact ⟨a :: pre, post, rfl, List.mem_cons_of_mem _ hy⟩

/-- `EmitRel` at a split of its output: the item there and those before have their sources at
a split of the input. -/
theorem EmitRel.split {xr : Reg} (pre : List Item) : ∀ {es its : List Item} {x : Item}
    {post : List Item}, EmitRel xr es its → es = pre ++ x :: post →
    ∃ pre' x' post', its = pre' ++ x' :: post' ∧ EmitRel xr pre pre' ∧
      (x = ren xr x' ∨ ∃ i : Nat, x = withRm (ren xr x') (.reg pool[i]!)) := by
  induction pre with
  | nil =>
    intro es its x post h e
    subst e
    cases h with
    | cons he _ => exact ⟨[], _, _, rfl, .nil, he⟩
  | cons a pre ih =>
    intro es its x post h e
    subst e
    cases h with
    | cons he hr =>
      obtain ⟨pre', x', post', h1, h2, h3⟩ := ih hr rfl
      exact ⟨_ :: pre', x', post', by simp [h1], .cons he h2, h3⟩

theorem EmitRel.mem' {xr : Reg} {es its : List Item} (h : EmitRel xr es its) {y : Item}
    (hy : y ∈ es) :
    ∃ y' ∈ its, (y = ren xr y' ∨ ∃ i : Nat, y = withRm (ren xr y') (.reg pool[i]!)) := by
  revert hy
  induction h with
  | nil => intro hy; cases hy
  | @cons e it es its he _ ih =>
    intro hy
    rcases List.mem_cons.1 hy with rfl | hy'
    · exact ⟨it, List.mem_cons.2 (.inl rfl), he⟩
    · obtain ⟨y', h1, h2⟩ := ih hy'
      exact ⟨y', List.mem_cons_of_mem _ h1, h2⟩

/-- What `emit` makes of a frame store: a frame store at the same place, from `rcx` if the
source's is. -/
theorem rel_st_frame {xr : Reg} {e : Item} {w : W} {r : Reg} {d : BitVec 32}
    (h : e = ren xr (.st w r (M.frame d)) ∨
      ∃ i : Nat, e = withRm (ren xr (.st w r (M.frame d))) (.reg pool[i]!)) :
    ∃ r2, e = .st w r2 (M.frame d) ∧ (r = .rcx → r2 = .rcx) := by
  rcases h with rfl | ⟨i, rfl⟩ <;> exact ⟨_, rfl, fun hr => by subst hr; rfl⟩

/-- A store not from `rcx`. -/
def isStNR (it : Item) : Bool :=
  match it with
  | .st _ r _ => r != .rcx
  | _ => false

/-- No possible frame writer before a store not from `rcx`. -/
def preNR : List Item → Bool
  | [] => true
  | y :: l => (!pw y || !(l.any isStNR)) && preNR l

theorem preNR_spec : ∀ (pre : List Item) {x : Item} {post : List Item},
    preNR (pre ++ x :: post) = true → isStNR x = true → ∀ y ∈ pre, pw y = false
  | [], _, _, _, _, y, hy => by cases hy
  | a :: pre, x, post, h, hx, y, hy => by
    simp only [List.cons_append, preNR, Bool.and_eq_true, Bool.or_eq_true,
      Bool.not_eq_true'] at h
    rcases List.mem_cons.1 hy with rfl | hy'
    · rcases h.1 with h1 | h1
      · exact h1
      · exfalso
        have : (pre ++ x :: post).any isStNR = true := List.any_eq_true.2 ⟨x, by simp, hx⟩
        rw [this] at h1
        cases h1
    · exact preNR_spec pre h.2 hx y hy'

/-- (DS-T9) An overflow op's sequence: no frame writer before its result store (the only store
not from `rcx`). -/
theorem seq_preNR {T : Type} {cls : Class} {ops : List (R.Opnd T)} {cand : List Item}
    {br : Option Cond} (h : sequence cls ops = some (cand, br)) (hc : isOvf cls = true) :
    preNR cand = true := by
  cases cls <;> simp only [isOvf, Bool.false_eq_true] at hc
  all_goals seq_open0
  all_goals rfl

/-- (DS-T9) An overflow op's only store from `rcx` is its flag store `mov [o], cl`. -/
theorem seq_ovf_rcx {T : Type} {cls : Class} {ops : List (R.Opnd T)} {cand : List Item}
    {br : Option Cond} (h : sequence cls ops = some (cand, br)) (hc : isOvf cls = true)
    {w : W} {m : M} (hx : Item.st w .rcx m ∈ cand) :
    ∃ s, ops[1]? = some (.slot s) ∧ w = .b ∧ m = M.frame s := by
  cases cls <;> simp only [isOvf, Bool.false_eq_true] at hc
  all_goals seq_open0
  all_goals simp [flagSeq, Asm.ld, Asm.st, Asm.C, Asm.R] at hx
  all_goals first
    | exact ⟨_, ‹_›, hx⟩
    | (obtain ⟨rfl, rfl⟩ := hx; exact ⟨_, ‹_›, rfl, rfl⟩)

/-- (DS-T9) `mov128`'s sequence: the high halves, then the low ones. -/
theorem seq_mov128 {T : Type} {ops : List (R.Opnd T)} {cand : List Item} {br : Option Cond}
    (h : sequence .mov128 ops = some (cand, br)) :
    ∃ a b : BitVec 32, b.toInt + 8 < 2 ^ 31 ∧
      cand = [Asm.ld .q (M.frame a), .ld .q false Asm.C (M.frame (a + 8)),
        .st .q Asm.C (M.frame (b + 8)), Asm.st .q (M.frame b)] := by
  seq_open0
  all_goals
    have hg := ‹¬((_ || _) = true)›
    simp only [Bool.or_eq_true, decide_eq_true_eq, not_or, M.frame, Int.not_le,
      ge_iff_le] at hg
    refine ⟨_, _, ?_, rfl⟩
    simp only [M.frame] at hg ⊢
    omega

end Ryo.Proofs.CacheStep

namespace Ryo.Proofs.DeadStore

open Ryo.Spec Ryo.Vm Ryo.Vm.R Ryo.X86 Ryo.Vm.Asm Ryo.Proofs.DecodeSound Ryo.Proofs.DecodeLink
  Ryo.Proofs.RegCache

/-- The simulation's targets after `s.pc`, on `DInv`. -/
abbrev DNext (S : Setup) (oc : Option (Cert S)) (s : R.RState) : X86.State → Prop :=
  Next S.c (DInv S oc) (ExitRel S) s

/-- `BodySim` on the ghost: the real `x` agrees with a ghost `xh` at the body's start. -/
def DBodySim (S : Setup) (oc : Option (Cert S)) (k p : Nat) (cache : Cache) : Prop :=
  ∀ s x P xh, s.pc = k → GhostOk S oc s P → KrOk S oc s P → FrameInvR S s xh → XAgree S P x xh →
    xh.rip = addrAt S.ctx p → CacheInv cache (S.virt xh) → RSafe S.Safe S.c s →
    Reach S.ctx S.E (DNext S oc s) x

/-- `InsnSimAt` on `DInv`. -/
def DInsnSimAt (S : Setup) (oc : Option (Cert S)) (k : Nat) : Prop :=
  ∀ s x, s.pc = k → DInv S oc s x → RSafe S.Safe S.c s → Reach S.ctx S.E (DNext S oc s) x

section

variable {S : Setup} {code : ByteArray} {relocs : Array Reloc} {rodata : ByteArray}
  {callSites : Array CallSite} {dropped : Array DroppedStore} {scopes : Array R.Scope}
  {mode : Ryo.Obj.Mode}

/-- The facts every ghost step needs beyond `Hyps`. -/
structure DHyps (S : Setup) (oc : Option (Cert S)) : Prop where
  none_empty : oc = none → S.c.d.dropped.isEmpty = true
  facts : ∀ C, oc = some C → FactsAgree C.facts S.c
  fpExact : FootprintExact
  /-- The dropped stores are `mov [rbp + off], r` (`DroppedStore.ofParts?`, `DecodeObj`). -/
  forms : ∀ k, ∀ d ∈ S.dr k, DroppedForm d
  /-- **Open** (a decoder fact or check): an iteration that starts with a dropped store
  (`Iter.empty`, read with the uncleared cache `S.cache k`) isn't at a branch target, so the
  cache there is `S.used k`. -/
  emptyNotTarget : ∀ k, k < S.r.protos.size → ∀ d dr, S.dr k = d :: dr → d.at_ = S.start k →
    sortedContains S.targets (S.start k) = false
  /-- **Environment assumption**: every answer the environment gives a query of this function
  satisfies `AnswerOk`, i.e. an island's answer writes every `Lend` extent of the instruction,
  and a call's returned registers hold their full widths. `R.answer` alone doesn't ensure it
  (`writeRanges` skips an empty answer; `retRegs` takes prefixes of the registers); the x86
  callee and island templates do (they write the extents and return 64-bit registers). -/
  answers : ∀ (s : R.RState) ch q s1 a o, R.step S.c s ch = .ok (.ext q s1) →
    R.answer S.c s1 a = .ok o → AnswerOk S s a
  /-- **Layout assumption**: no image address (`Ctx.addrOf`: a symbol slot, the rodata, the JIT
  record), nor the 8 bytes from it, is a byte of the frame window: the image's sections are
  apart from the stack. A kept `loadRip` reads such a slot (`kept_loadRip_apart`). -/
  imageOffFrame : ∀ (to : X86.Ref) (j : Nat), j < 8 → ∀ o : Int,
    -(S.c.d.frameSize : Int) ≤ o → o < S.K → S.ctx.addrOf to + BitVec.ofNat 64 j ≠ S.winAddr o

/-- `reducedOf`'s `items`: the protos'. -/
theorem sim_reducedOf_items {r : ReadResult} {pe : Bool} {d : Decoded}
    (h : reducedOf r pe = .ok d) : d.items = r.protos.map (·.items) := by
  unfold reducedOf at h
  obtain ⟨insns, -, h2⟩ := ebind_ok h
  obtain ⟨head, -, h3⟩ := ebind_ok h2
  cases h3
  rfl

/-- Inline instruction `k`'s R instruction and items, from its read. -/
theorem dinline_insn (H : Hyps S) {k p : Nat} {cache : Cache} {q : Proto} {c' : Cursor}
    {cache' : Cache} {dr' : List DroppedStore} (hP : ProtoFacts S k p q c' cache')
    (hr : (inlineInsn cache (S.dr k) true).run (atPos S.body p) =
      .ok (some (q, cache', dr'), c')) :
    ∃ op ops cls, S.c.d.insns[k]? = some (.native op ops) ∧ op.full = some q.op ∧
      (q.op, cls) ∈ inlineOps ∧ (S.r.protos[k]'hP.lt).items = q.items := by
  have hk := hP.lt
  obtain ⟨-, hh, cand, br, out, hdi, -⟩ := inlineInsn_read_drop hr
  obtain ⟨cls, hmem, -⟩ := decodeInline_spec hdi
  obtain ⟨i, hi, hio⟩ := hP.insn
  obtain ⟨p1, counter, hpk⟩ := hP.proto
  have hpk' : S.r.protos[k] = { q with pos := p1, counter } := by
    rw [Array.getElem?_eq_getElem hk] at hpk; exact Option.some.inj hpk
  have hio' := hio hk
  rw [hpk'] at hio'
  unfold InsnOf at hio'
  simp only [hh] at hio'
  obtain ⟨op, ops, hof, rfl, -⟩ := hio'
  exact ⟨op, ops, cls, hi, inline_full_of hof, hmem, by rw [hpk']⟩

/-! ### The real machine against the ghost, at boundaries -/

/-- Without a patch set the real machine is the ghost. -/
theorem xAgree_none_eq {P : Int → Prop} (hP : ∀ o, ¬ P o) {x xh : X86.State}
    (h : XAgree S P x xh) : x = xh := by
  obtain ⟨h1, h2, h3, h4, h5⟩ := h
  have hm : x.mem = xh.mem := funext fun a => h5 a (fun o ho => absurd ho (hP o))
  cases x
  cases xh
  simp only [X86.State.mk.injEq]
  exact ⟨h1, h4, h3, h2, hm⟩

/-- The ghost re-jumped to a real state with the same registers, flags and memory. -/
theorem xAgree_jump {P : Int → Prop} {x xh y : X86.State} (ha : XAgree S P x xh)
    (hr : y.regs = x.regs) (hx : y.xmm = x.xmm) (hf : y.flags = x.flags) (hm : y.mem = x.mem) :
    XAgree S P y (xh.jump y.rip) := by
  obtain ⟨h1, h2, h3, -, h5⟩ := ha
  have hv : vfp S (xh.jump y.rip) = vfp S xh := by
    unfold vfp
    rw [setup_virt_jump]
    rfl
  unfold XAgree XAgreeAt
  rw [hv]
  refine ⟨hr.trans h1, hx.trans h2, hf.trans h3, rfl, ?_⟩
  intro a hna
  rw [hm]
  exact h5 a hna

/-- The R state the real machine relates to: `s` without a certificate, else the shadow. -/
noncomputable def shadowOf (oc : Option (Cert S)) (s : R.RState) (P : Int → Prop) : R.RState :=
  match oc with
  | none => s
  | some _ => erase s P

theorem shadowOf_pc (oc : Option (Cert S)) (s : R.RState) (P : Int → Prop) :
    (shadowOf oc s P).pc = s.pc := by
  cases oc <;> rfl

/-- The real machine relates to the shadow (`frameInvR_erase`; `x` is the ghost without a
certificate). -/
theorem dinv_shadow (H : Hyps S) {oc : Option (Cert S)} {s : R.RState} {P : Int → Prop}
    {x xh : X86.State} (hg : GhostOk S oc s P) (hfr : FrameInvR S s xh) (ha : XAgree S P x xh)
    (hkn : s.pc < S.c.d.insns.size) : FrameInvR S (shadowOf oc s P) x := by
  cases oc with
  | none =>
    have hx := xAgree_none_eq hg ha
    subst hx
    exact hfr
  | some C =>
    obtain ⟨hpat, hesc⟩ := hg
    exact frameInvR_erase H C hfr ha hpat (hesc hkn)

/-- The shadow holds `Uninit` at `P`. -/
theorem ds_erase_uninit {s : R.RState} {P : Int → Prop}
    (hpriv : ∀ o, P o → s.st.escapedAt o = none) :
    ∀ o, P o → (erase s P).st.byteAt o = .ok .uninit := by
  intro o ho
  have he : (erase s P).st.escapedAt o = none := hpriv o ho
  rw [ds_byteAt_of_none he]
  simp [erase, eraseSt, ho]

theorem ds_rAgree_erase (s : R.RState) (P : Int → Prop) : RAgree P s (erase s P) := by
  refine ⟨rfl, rfl, rfl, ?_⟩
  show StEq (eraseSt P s.st) (eraseSt P (eraseSt P s.st))
  rw [eraseSt_idem]
  exact ⟨rfl, rfl, rfl, rfl, rfl, fun _ _ => rfl⟩

/-- At an `EmptyAt` boundary the cache caches no slot (`slotless_empty`): `binv_of_agree`'s
position hypothesis. -/
theorem hpos_of_empty {s' t : R.RState} {x' : X86.State} {P' : Int → Prop}
    (hemp : EmptyAt S t.pc x') :
    ∃ c : Asm.Cache, ((x'.rip = addrAt S.ctx (S.start t.pc) ∧ c = S.cache t.pc) ∨
        (x'.rip = addrAt S.ctx (posOf S.r t.pc) ∧ c = S.used t.pc)) ∧ CacheInv c (S.virt x') ∧
      ∀ e ∈ c.regs.toList, ∀ sl w, e.slot = some (sl, w) → ∀ o, P' o →
        sl.toInt ≤ o → o < sl.toInt + Asm.bytes w → s'.st.byteAt o = .ok .uninit := by
  rcases hemp with ⟨h1, h2⟩ | ⟨h1, h2⟩
  · refine ⟨_, .inl ⟨h1, rfl⟩, (by rw [h2]; exact CacheInv.emptyPe _ _), ?_⟩
    intro e he sl w hs
    rw [h2] at he
    rw [slotless_empty _ e he] at hs
    cases hs
  · refine ⟨_, .inr ⟨h1, rfl⟩, (by rw [h2]; exact CacheInv.emptyPe _ _), ?_⟩
    intro e he sl w hs
    rw [h2] at he
    rw [slotless_empty _ e he] at hs
    cases hs

/-- `dinv_of_agree` at a boundary whose cache is empty (`EmptyAt`: it caches no slot). -/
theorem dinv_of_agree_empty (H : Hyps S) (C : Cert S) {s' t' : R.RState} {x' : X86.State}
    {P' : Int → Prop} (hfr : FrameInvR S t' x') (hemp : EmptyAt S t'.pc x')
    (hag : RAgree P' s' t') (hun : ∀ o, P' o → t'.st.byteAt o = .ok .uninit)
    (hP : PatchOk S C s' P') (he : EscSound S C s') (hkr : KrInv S C s' P') :
    DInv S (some C) s' x' :=
  dinv_of_agree H C hfr (hpos_of_empty hemp) hag hun hP he hkr

/-- Re-ghost a real state related to the shadow at an empty-cache boundary (`dinv_of_agree`). -/
theorem dinv_reghost (H : Hyps S) {oc : Option (Cert S)} {s : R.RState} {P : Int → Prop}
    (hg : GhostOk S oc s P) (hkr : KrOk S oc s P) (hkn : s.pc < S.c.d.insns.size)
    {z : X86.State} (hfz : FrameInvR S (shadowOf oc s P) z)
    (hemp : S.used s.pc = { pe := S.c.mode.pe }) :
    DInv S oc s (z.jump (addrAt S.ctx (posOf S.r s.pc))) := by
  cases oc with
  | none =>
    have hfz' : FrameInvR S s z := hfz
    exact dinv_of_binv (vt_bInv_used hfz' (by rw [hemp]; exact CacheInv.emptyPe _ _))
      (fun C hC => by cases hC)
  | some C =>
    have hfz' : FrameInvR S (erase s P) z := hfz
    obtain ⟨hpat, hesc⟩ := hg
    exact dinv_of_agree_empty H C (frameInvR_jump _ hfz') (.inr ⟨rfl, hemp⟩) (ds_rAgree_erase s P)
      (ds_erase_uninit fun o ho => (hpat o ho).2.2.1) hpat (hesc hkn) (hkr C rfl hkn)

/-- A `DInv` boundary as a body's hypotheses on a real state with the same registers, flags and
memory (the ghost re-jumped to its `rip`). -/
theorem dinv_at {oc : Option (Cert S)} {s : R.RState} {x : X86.State} (h : DInv S oc s x)
    (y : X86.State) (hr : y.regs = x.regs) (hx : y.xmm = x.xmm) (hf : y.flags = x.flags)
    (hm : y.mem = x.mem) :
    ∃ P xh, GhostOk S oc s P ∧ KrOk S oc s P ∧ FrameInvR S s xh ∧ XAgree S P y xh ∧
      xh.rip = y.rip ∧
      (S.used s.pc = { pe := S.c.mode.pe } → CacheInv (S.used s.pc) (S.virt xh)) := by
  obtain ⟨P, xh, hg, hbi, ha, hkr⟩ := h
  exact ⟨P, xh.jump y.rip, hg, hkr, frameInvR_jump _ hbi.1, xAgree_jump ha hr hx hf hm, rfl,
    fun he => by rw [he]; exact CacheInv.emptyPe _ _⟩

/-! ### Non-inline opcodes have no class (kernel evaluation, as `classOf_arg`) -/

theorem classOf_call : classOf Full.Opcode.call = none := by
  have hm : Full.Opcode.call.mnemonic = String.ofList ['c', 'a', 'l', 'l'] := by decide +kernel
  unfold classOf
  rw [hm, ← dsClassOfL_eq]
  decide +kernel

theorem classOf_callSym : classOf Full.Opcode.callSym = none := by
  have hm : Full.Opcode.callSym.mnemonic = String.ofList ['c', 'a', 'l', 'l', '.', 's', 'y', 'm'] := by decide +kernel
  unfold classOf
  rw [hm, ← dsClassOfL_eq]
  decide +kernel

theorem classOf_callSymInd : classOf Full.Opcode.callSymInd = none := by
  have hm : Full.Opcode.callSymInd.mnemonic = String.ofList ['c', 'a', 'l', 'l', '.', 's', 'y', 'm', '.', 'i', 'n', 'd'] := by decide +kernel
  unfold classOf
  rw [hm, ← dsClassOfL_eq]
  decide +kernel

theorem classOf_callPtr : classOf Full.Opcode.callPtr = none := by
  have hm : Full.Opcode.callPtr.mnemonic = String.ofList ['c', 'a', 'l', 'l', '.', 'p', 't', 'r'] := by decide +kernel
  unfold classOf
  rw [hm, ← dsClassOfL_eq]
  decide +kernel

theorem classOf_tailCall : classOf Full.Opcode.tailCall = none := by
  have hm : Full.Opcode.tailCall.mnemonic = String.ofList ['t', 'a', 'i', 'l', '_', 'c', 'a', 'l', 'l'] := by decide +kernel
  unfold classOf
  rw [hm, ← dsClassOfL_eq]
  decide +kernel

theorem classOf_tailCallPtr : classOf Full.Opcode.tailCallPtr = none := by
  have hm : Full.Opcode.tailCallPtr.mnemonic = String.ofList ['t', 'a', 'i', 'l', '_', 'c', 'a', 'l', 'l', '.', 'p', 't', 'r'] := by decide +kernel
  unfold classOf
  rw [hm, ← dsClassOfL_eq]
  decide +kernel

theorem classOf_ret : classOf Full.Opcode.ret = none := by
  have hm : Full.Opcode.ret.mnemonic = String.ofList ['r', 'e', 't'] := by decide +kernel
  unfold classOf
  rw [hm, ← dsClassOfL_eq]
  decide +kernel

theorem classOf_unreachable : classOf Full.Opcode.unreachable = none := by
  have hm : Full.Opcode.unreachable.mnemonic = String.ofList ['u', 'n', 'r', 'e', 'a', 'c', 'h', 'a', 'b', 'l', 'e'] := by decide +kernel
  unfold classOf
  rw [hm, ← dsClassOfL_eq]
  decide +kernel

theorem classOf_jmp : classOf Full.Opcode.jmp = none := by
  have hm : Full.Opcode.jmp.mnemonic = String.ofList ['j', 'm', 'p'] := by decide +kernel
  unfold classOf
  rw [hm, ← dsClassOfL_eq]
  decide +kernel

theorem classOf_island : classOf Full.Opcode.island = none := by
  have hm : Full.Opcode.island.mnemonic = String.ofList ['i', 's', 'l', 'a', 'n', 'd'] := by decide +kernel
  unfold classOf
  rw [hm, ← dsClassOfL_eq]
  decide +kernel

/-- A call's opcode (`callHead`'s) has no class. -/
theorem callHead_classOf {f : Full.Opcode} {fo : R.Opnd Nat} {r : List Item × Item}
    (h : Call.callHead f fo = some r) : classOf f = none := by
  cases fo with
  | func g =>
    simp only [Call.callHead] at h
    split at h
    · rename_i he
      have hf : f = .call := by first | exact eq_of_beq he | simpa using he
      rw [hf]; exact classOf_call
    · cases h
  | sym g =>
    simp only [Call.callHead] at h
    split at h
    · rename_i he
      have hf : f = .callSym := by first | exact eq_of_beq he | simpa using he
      rw [hf]; exact classOf_callSym
    · split at h
      · rename_i he
        have hf : f = .callSymInd := by first | exact eq_of_beq he | simpa using he
        rw [hf]; exact classOf_callSymInd
      · cases h
  | slot g =>
    simp only [Call.callHead] at h
    split at h
    · rename_i he
      have hf : f = .callPtr := by first | exact eq_of_beq he | simpa using he
      rw [hf]; exact classOf_callPtr
    · cases h
  | _ => simp [Call.callHead] at h

/-- A tail call's opcode (`tailHead`'s) has no class. -/
theorem tailHead_classOf {w : Bool} {f : Full.Opcode} {fo : R.Opnd Nat}
    {r : List Item × Item} (h : Call.tailHead w f fo = some r) : classOf f = none := by
  cases fo with
  | func g =>
    simp only [Call.tailHead] at h
    split at h
    · rename_i he
      have hf : f = .tailCall := by first | exact eq_of_beq he | simpa using he
      rw [hf]; exact classOf_tailCall
    · cases h
  | slot g =>
    simp only [Call.tailHead] at h
    split at h
    · rename_i he
      have hf : f = .tailCallPtr := by first | exact eq_of_beq he | simpa using he
      rw [hf]; exact classOf_tailCallPtr
    · cases h
  | _ => simp [Call.tailHead] at h

/-- A proto whose op has no class, or with a handler, isn't an `InlineAt` instruction. -/
theorem not_inlineAt_of_class {k p : Nat} {q : Proto} {c' : Cursor} {cache' : Cache}
    (hP : ProtoFacts S k p q c' cache') (h : classOf q.op = none ∨ q.handler.isSome = true) :
    ¬ InlineAt S k := by
  rintro ⟨op, ops, hi, hcl⟩
  obtain ⟨i, hi', hio⟩ := hP.insn
  rw [hi] at hi'
  cases hi'
  obtain ⟨p1, counter, hpk⟩ := hP.proto
  have hk := hP.lt
  have hpk' : S.r.protos[k] = { q with pos := p1, counter } := by
    rw [Array.getElem?_eq_getElem hk] at hpk; exact Option.some.inj hpk
  have hio' := hio hk
  rw [hpk'] at hio'
  unfold InsnOf at hio'
  cases hh : q.handler with
  | some a =>
    simp only [hh] at hio'
    obtain ⟨t', he, -⟩ := hio'
    cases he
  | none =>
    simp only [hh] at hio'
    obtain ⟨op', ops', hof, he, -⟩ := hio'
    cases he
    have hf := inline_full_of hof
    rcases h with h | h
    · rw [hf] at hcl
      simp [h] at hcl
    · rw [hh] at h
      cases h

/-- T6: a non-inline body holds without the cache (`BodySimB`: the bodies don't read it; some
boundary relation at `s` stands in for `CodeApart`'s live allocations). -/
theorem bodySim_noninline_empty (hD : Decodes S code relocs rodata callSites dropped scopes mode)
    (H : Hyps S) {k p : Nat} {q : Proto} {c' : Cursor} {cache' : Cache}
    {dr' : List DroppedStore} (hP : ProtoFacts S k p q c' cache')
    (hr : ProtoRead S.fr S.ro true S.body p (S.used k) (S.dr k) (S.args k) q c' cache' dr')
    (htable : HdlTables S) (hni : ¬ InlineAt S k) :
    BodySimBE S k p := by
  generalize ha : S.args k = a at hr
  cases hr with
  | arg h => exact bodySim_argB hD H ha hP h
  | call hn h => exact bodySim_call'B hD H hP hn h
  | inline hn hc h =>
    exfalso
    have e := callInsn_none hc
    have hcur := (hn : _ = atPos S.body p)
    rw [e, hcur] at h
    obtain ⟨op, ops, cls, hi, hfull, hmem, -⟩ := dinline_insn H hP h
    exact hni ⟨op, ops, hi, by simp [hfull, classOf_of_mem hmem]⟩
  | insn hn hc hi h =>
    have e1 := callInsn_none hc
    have e2 := inlineInsn_none hi
    subst e1 e2
    rcases insn_split h with hd | ⟨hnd, hcore⟩
    · exact bodySim_denseB hD H hP hn hd htable
    have hir := insnCore_read hcore
    have hir' := hir
    cases hir' with
    | handler => exact bodySim_handler'B hD H hP hn hir (by simp) hnd htable
    | ret => exact bodySim_retB hD H hP hn hir rfl
    | unreachable => exact bodySim_unreachableB hD H hP hn hir rfl
    | jmp => exact bodySim_jmpB hD H hP hn hir rfl
    | island => exact bodySim_islandB hD H hP hn hir rfl
    | resume => exact bodySim_handler'B hD H hP hn hir (by simp) hnd htable
    | dense h => exact (hnd _ h).elim

/-- A target of an operand of native instruction `k`, in range, is one of `flow`'s successors
of `k` (`flow_succ_target` for any operand's targets). -/
theorem flow_succ_targetsOf {d : Decoded} {k : Nat} {op : Reduced.Opcode} {ops : List (Opnd Nat)}
    (hi : d.insns[k]? = some (.native op ops)) {o : Opnd Nat} (ho : o ∈ ops) {t : Nat}
    (ht : t ∈ o.targetsOf) (htn : t < d.insns.size) : t ∈ (Frame.flow d).1[k]! := by
  have hk : k < d.insns.size := by
    rcases Nat.lt_or_ge k d.insns.size with h | h
    · exact h
    · rw [Array.getElem?_eq_none h] at hi; cases hi
  unfold Frame.flow
  simp only [Id.run_bind, Id.run_pure, Std.Legacy.Range.forIn'_eq_forIn'_range',
    Std.Legacy.Range.size]
  refine forIn'_push_mem (R := fun a x => ∀ op ops, d.insns[a]? = some (.native op ops) →
    ∀ o ∈ ops, ∀ t ∈ Opnd.targetsOf o, t < d.insns.size → t ∈ x) _ ?_ (by simpa using hk)
    (fun x hR => hR op ops hi o ho t ht htn)
  intro a h b
  refine ⟨_, rfl, ?_⟩
  intro op' ops' hop o' ho' t' ht' htn'
  have hd : ∀ hh : a < d.insns.size, d.insns[a]'hh = .native op' ops' := fun hh => by
    rw [Array.getElem?_eq_getElem hh] at hop
    exact Option.some.inj hop
  simp only [hd]
  exact List.mem_filter.2 ⟨List.mem_append_right _
    (List.mem_flatMap.2 ⟨o', ho', ht'⟩), by simpa using htn'⟩

/-- R's successors of instruction `k` (`RSucc.Succ`'s next one and targets), in range, are
`flow`'s: `flow` takes the next one exactly when `insnFalls` does, and the targets. -/
theorem flow_succ_succ {d : Decoded} {k : Nat} {i : R.Insn} (hi : d.insns[k]? = some i)
    {t : Nat} (ht : (t = k + 1 ∧ RSucc.insnFalls i = true) ∨ t ∈ RSucc.insnTargets i)
    (htn : t < d.insns.size) : t ∈ (Frame.flow d).1[k]! := by
  have hk : k < d.insns.size := by
    rcases Nat.lt_or_ge k d.insns.size with h | h
    · exact h
    · rw [Array.getElem?_eq_none h] at hi; cases hi
  unfold Frame.flow
  simp only [Id.run_bind, Id.run_pure, Std.Legacy.Range.forIn'_eq_forIn'_range',
    Std.Legacy.Range.size]
  refine forIn'_push_mem (R := fun a x => ∀ i, d.insns[a]? = some i → ∀ t,
    ((t = a + 1 ∧ RSucc.insnFalls i = true) ∨ t ∈ RSucc.insnTargets i) →
      t < d.insns.size → t ∈ x) _ ?_ (by simpa using hk) (fun x hR => hR i hi t ht htn)
  intro a h b
  refine ⟨_, rfl, ?_⟩
  intro i' hi' t' ht' htn'
  cases i' with
  | native op ops =>
    have hd : ∀ hh : a < d.insns.size, d.insns[a]'hh = .native op ops := fun hh => by
      rw [Array.getElem?_eq_getElem hh] at hi'
      exact Option.some.inj hi'
    simp only [hd]
    refine List.mem_filter.2 ⟨?_, by simpa using htn'⟩
    rcases ht' with ⟨rfl, hf⟩ | ht'
    · refine List.mem_append_left _ ?_
      simp only [RSucc.insnFalls] at hf
      first
        | simp [hf, htn']
        | (simp only [Bool.not_or] at hf; simp [hf, htn'])
        | simp_all
    · exact List.mem_append_right _ ht'
  | handler h args t =>
    have hd : ∀ hh : a < d.insns.size, d.insns[a]'hh = .handler h args t := fun hh => by
      rw [Array.getElem?_eq_getElem hh] at hi'
      exact Option.some.inj hi'
    simp only [hd]
    refine List.mem_filter.2 ⟨?_, by simpa using htn'⟩
    rcases ht' with ⟨rfl, hf⟩ | ht'
    · refine List.mem_append_left _ ?_
      simp only [RSucc.insnFalls] at hf
      first
        | simp [hf, htn']
        | (simp only [Bool.not_or] at hf; simp [hf, htn'])
        | simp_all
    · exact List.mem_append_right _ ht'

/-- R's successor of a non-inline instruction is a flow edge in range, or past the code
(`RSucc.rnext_succ`: the next one, a target, or a landing pad). -/
theorem rnext_flow_edge (hD : Decodes S code relocs rodata callSites dropped scopes mode)
    (C : Cert S) {s s' : R.RState} {P : Int → Prop} (hpre : StepPre S C s P)
    (hn : RNext S.c s s') :
    (s'.pc ∈ C.fl.succ[s.pc]! ∧ s'.pc < S.c.d.insns.size) ∨
      (s'.pc ∈ C.fl.pad[s.pc]! ∧ s'.pc < S.c.d.insns.size) ∨ S.c.d.insns.size ≤ s'.pc := by
  have hk' : s.pc < S.c.d.insns.size := hpre.lt
  obtain ⟨i, hi, hsu⟩ := RSucc.rnext_succ hn
  rcases hsu with ⟨hp1, hfa⟩ | htg | ⟨pad, b, hcl, hp⟩
  · rcases Nat.lt_or_ge s'.pc S.c.d.insns.size with hlt | hge
    · left
      refine ⟨?_, hlt⟩
      rw [flowOf_succ C.hfl]
      exact flow_succ_succ hi (.inl ⟨hp1, hfa⟩) hlt
    · exact .inr (.inr hge)
  · have hii : S.c.d.insns[s.pc] = i := by
      rw [Array.getElem?_eq_getElem hk'] at hi
      exact Option.some.inj hi
    have hlt : s'.pc < S.c.d.insns.size := (reducedOf_insns hD.reduced).1 ▸
      reducedOf_targets_lt hD.reduced s.pc hk' s'.pc (by rw [hii]; exact htg)
    left
    refine ⟨?_, hlt⟩
    rw [flowOf_succ C.hfl]
    exact flow_succ_succ hi (.inr htg) hlt
  · have hlt : pad < S.c.d.insns.size := hpre.padRange pad b hcl
    right; left
    rw [hp]
    refine ⟨?_, hlt⟩
    rw [flowOf_pad C.hfl]
    exact flow_pad_mem hcl hk' hlt

/-- Proto `j` with op `arg` was read while `S.args j` held: only `argInsn` reads an `arg`
(`argsOk_proto`'s case split; `argsOk_*_ne` for the other readers). -/
theorem args_of_argOp (hD : Decodes S code relocs rodata callSites dropped scopes mode)
    (H : Hyps S) {j : Nat} (hj : j < S.r.protos.toList.length)
    (hop : S.r.protos.toList[j].op = .arg) : S.args j = true := by
  have hInl := H.inlineOk
  obtain ⟨fr, q0, p', ca', dr', hfm, hpq, it, -⟩ := hD.iterAt j hj
  have hpr0 : S.r.protos.toList[j] = q0 := by
    rcases hpq with h | h
    · exact h
    · rw [h]; refine S.fixResume_of_ne ?_
      rw [← (S.fixResume_keep q0).1, ← h, hop]; decide
  rw [hpr0] at hop
  generalize S.cache j = c0 at it
  generalize ha : S.args j = a0 at it
  generalize S.start j = s0 at it
  generalize S.dr j = d0 at it
  cases it with
  | empty _ hin =>
    exact absurd (by simpa using hop) (argsOk_inline_ne hInl hin)
  | @main _ _ _ _ _ _ _ _ q _ _ _ hpr _ =>
    have hq : q.op = .arg := hop
    cases hpr with
    | arg _ => rfl
    | call _ h => exact (argsOk_call_ne h hq).elim
    | inline _ _ hin =>
      have hin' : (inlineInsn _ _ true).run _ = .ok (some (q, _, _), _) := hin
      exact (argsOk_inline_ne hInl hin' hq).elim
    | insn _ _ _ h => exact (argsOk_insn_ne h hq).elim

/-- `StepPre` at a non-inline instruction from the ghost's relation. -/
theorem dnoninline_pre (hD : Decodes S code relocs rodata callSites dropped scopes mode)
    (H : Hyps S) (C : Cert S) {oc : Option (Cert S)} (DH : DHyps S oc) (hC : oc = some C)
    {k p : Nat} {q : Proto} {c' : Cursor} {cache' : Cache} (hP : ProtoFacts S k p q c' cache')
    (hni : ¬ InlineAt S k) {s : R.RState} {P : Int → Prop} (hs : s.pc = k)
    (hpat : PatchOk S C s P) (hesc : EscSound S C s) {xh : X86.State} (hfr : FrameInvR S s xh)
    (hsafe : RSafe S.Safe S.c s) : StepPre S C s P := by
  have hkn : s.pc < S.c.d.insns.size := by
    rw [hs]; exact (reducedOf_insns hD.reduced).1 ▸ hP.lt
  have hni' : ¬ InlineAt S s.pc := by rw [hs]; exact hni
  -- A landing pad is an `lpad` proto (`pad_lpad`).
  have hpad : ∀ pad b, S.c.cleanupAt s.pc = some (some pad, b) → pad < S.c.d.insns.size :=
    fun pad b hcl => (reducedOf_insns hD.reduced).1 ▸ (pad_lpad hD hcl).1
  -- A `jmp`'s target is one of `reducedOf`'s targets (`reducedOf_targets_lt`).
  have hjmp : ∀ op f t, S.c.d.insns[s.pc]? = some (.native op [.target t]) → op.full = some f →
      f.info.shape = .jmp → t < S.c.d.insns.size := by
    intro op f t hi _ _
    have hii : S.c.d.insns[s.pc] = .native op [.target t] := by
      rw [Array.getElem?_eq_getElem hkn] at hi
      exact Option.some.inj hi
    have ht := reducedOf_targets_lt hD.reduced s.pc hkn t
      (by rw [hii]; simp [RSucc.insnTargets, Opnd.targetsOf])
    exact (reducedOf_insns hD.reduced).1 ▸ ht
  -- The instruction's targets are instructions (`reducedOf_targets_lt`).
  have htg : ∀ i, S.c.d.insns[s.pc]? = some i → ∀ y ∈ RSucc.insnTargets i,
      y < S.c.d.insns.size := by
    intro i hi y hy
    have hii : S.c.d.insns[s.pc] = i := by
      rw [Array.getElem?_eq_getElem hkn] at hi
      exact Option.some.inj hi
    exact (reducedOf_insns hD.reduced).1 ▸
      reducedOf_targets_lt hD.reduced s.pc hkn y (by rw [hii]; exact hy)
  have hkp : s.pc < S.r.protos.size := (reducedOf_insns hD.reduced).1 ▸ hkn
  have hpl : s.pc < S.r.protos.toList.length := by simpa using hkp
  -- An `arg` at `s.pc` is a leading one (`LeadArg`).
  have hlead : ∀ op f d r, S.c.d.insns[s.pc]? = some (.native op [.slot d, .imm r]) →
      op.full = some f → f.info.shape = .arg → LeadArg S s.pc := by
    intro op f d r hi hf hsh
    have hio := (reducedOf_insns hD.reduced).2 s.pc hkp hkn
    have hii : S.c.d.insns[s.pc] = .native op [.slot d, .imm r] := by
      rw [Array.getElem?_eq_getElem hkn] at hi; exact Option.some.inj hi
    rw [hii] at hio
    have hpa : S.r.protos[s.pc].op = .arg := by
      unfold InsnOf at hio
      split at hio
      · obtain ⟨t', he, -⟩ := hio
        cases he
      · obtain ⟨op1, ops1, hof, he, -⟩ := hio
        cases he
        have hf' := inline_full_of hof
        rw [hf] at hf'
        cases hf'
        exact privc_arg_of_shape hof hsh
    have hpa' : S.r.protos.toList[s.pc].op = .arg := by simpa using hpa
    have hargs := args_of_argOp hD H hpl hpa'
    refine ⟨hkp, ?_⟩
    simp [hD.argsSucc s.pc hpl, hargs, hpa, hpa']
  have hargLead : ∀ op f d r, S.c.d.insns[s.pc]? = some (.native op [.slot d, .imm r]) →
      op.full = some f → f.info.shape = .arg → ∀ j < s.pc, ∃ op' f' d' r',
        S.c.d.insns[j]? = some (.native op' [.slot d', .imm r']) ∧ op'.full = some f' ∧
        f'.info.shape = .arg := by
    intro op f d r hi hf hsh j hj
    have hl := hlead op f d r hi hf hsh
    have hjl : j < S.r.protos.toList.length := by omega
    have hops : S.r.protos.toList[j].op = .arg := lead_ops hD hpl hl.2 j (by omega)
    obtain ⟨a, d', hops', hh, -, -⟩ := argsOk_proto hD H.inlineOk hjl hops
    have hjp : j < S.r.protos.size := by simpa using hjl
    have hjk : j < S.c.d.insns.size := by omega
    have e : S.r.protos.toList[j] = S.r.protos[j] := by simp
    rw [e] at hops' hh hops
    have hio2 := (reducedOf_insns hD.reduced).2 j hjp hjk
    simp only [InsnOf, hh] at hio2
    obtain ⟨op', ops', hof', he', hm⟩ := hio2
    rw [hops'] at hm
    rcases ops' with _ | ⟨o1, _ | ⟨o2, _ | ⟨o3, l⟩⟩⟩ <;> simp at hm
    obtain ⟨h1, h2⟩ := hm
    cases o1 <;> simp [opndMap] at h1
    cases o2 <;> simp [opndMap] at h2
    rename_i d2 r2
    exact ⟨op', .arg, d2, r2, by rw [Array.getElem?_eq_getElem hjk, he'],
      by rw [inline_full_of hof', hops], argsOk_arg_shape⟩
  -- The `arg`'s register relates to the machine's (`FrameInv.args`, `ArgsLive`): its length.
  have hargLen : ∀ op f d r a, S.c.d.insns[s.pc]? = some (.native op [.slot d, .imm r]) →
      op.full = some f → f.info.shape = .arg →
      (∀ j < s.pc, ∃ op' f' d' r',
        S.c.d.insns[j]? = some (.native op' [.slot d', .imm r']) ∧ op'.full = some f' ∧
        f'.info.shape = .arg) →
      Asm.ArgReg.of? r.toNat true = some a → a.size ≤ (s.args.get (.ofArgReg a)).length := by
    intro op f d r a hi hf hsh _ hof
    have hl := hlead op f d r hi hf hsh
    have hat : ArgRegAt S s.pc (.ofArgReg a) := ⟨op, d, r, f, a, hi, hf, hsh, hof, rfl⟩
    have hrr := hfr.1.args hl (.ofArgReg a) (argsOk_conv hD H.inlineOk s.pc _ hl hat)
      (fun j hj hjr => argsOk_distinct hD H.argsChecked j s.pc _ hj hl hjr hat)
    have hb : Ryo.Proofs.Inline.BytesRel (s.args.get (.ofArgReg a))
        (ArgRet.argBytes S.c.mode.pe (S.virt xh) (.ofArgReg a)) := hrr
    rw [Ryo.Proofs.Inline.BytesRel.length hb]
    obtain ⟨hx, hg⟩ := ArgRet.argReg_of_spec hof
    cases hxa : a.xmm
    · have := hg hxa
      simp [R.Reg.ofArgReg, hxa, ArgRet.argBytes, leEncode_length] <;> omega
    · have := (hx hxa).1
      simp [R.Reg.ofArgReg, hxa, ArgRet.argBytes, leEncode_length] <;> omega
  refine ⟨H, DH.facts C hC, DH.fpExact, hpat, hesc, hkn, ⟨xh, hfr⟩, hsafe, hni', ?_, hpad, hjmp,
    ?_, hargLead, hargLen, ?_, ?_, ?_⟩
  · -- succRange
    intro h args t hi ctl y hy
    rcases RSucc.then_succ hy with ⟨rfl, -⟩ | hy
    · omega
    · exact Nat.le_of_lt (htg _ hi y hy)
  · -- argNext
    intro _ _ _ _ _ _ _
    omega
  · -- islandNext
    intro _ _ _ _ _ _ _
    omega
  · -- callNext
    intro _ _ _ _ _ _
    omega
  · -- nativeRange
    intro op ops f t ctl y hi _ hc hy
    rcases RSucc.then_succ hy with ⟨rfl, -⟩ | hy
    · omega
    · obtain ⟨o, hoo, hxo⟩ := inline_ctl_targets hc hy
      exact Nat.le_of_lt (htg _ hi y (List.mem_flatMap.2 ⟨o, hoo, hxo⟩))

/-- Re-ghost after a non-inline step run from the shadow `erase s P` (`rnext_erase`,
`rdone_erase`, `dinv_of_agree`). -/
theorem dnoninline_next (hD : Decodes S code relocs rodata callSites dropped scopes mode)
    (H : Hyps S) (C : Cert S) {oc : Option (Cert S)} (DH : DHyps S oc) {s : R.RState}
    {P : Int → Prop}
    (hpre : StepPre S C s P) (hkr0 : KrInv S C s P) {x' : X86.State}
    (hn : SNextE S (erase s P) x') :
    DNext S (some C) s x' := by
  rcases hn with ⟨t', hn', hb, hemp⟩ | ⟨f, hd, he⟩
  · have hans : ∀ ch q s1 a, R.step S.c (erase s P) ch = .ok (.ext q s1) →
        R.answer S.c s1 a = .ok (.step t') → AnswerOk S s a :=
      fun ch q s1 a h1 h2 => DH.answers (erase s P) ch q s1 a _ h1 h2
    obtain ⟨s', P', hPP, hkill, hendU, hns, hag, hun, hP', he'⟩ := rnext_erase C hpre hans hn'
    -- The boundary's cache is empty after a non-inline instruction (`SNextE`), so it caches
    -- no byte of `P'` (`hpos_of_empty`, for `binv_of_agree`).
    have hpos := hpos_of_empty (s' := s') (P' := P') (t := t') hemp
    have hk : s.pc < C.fl.succ.size := by
      rw [flowOf_succ C.hfl, flow_succ_size]; exact hpre.lt
    have hcv : ∀ kk o, kk ≤ S.c.d.insns.size → CacheCovers S kk o → InFrame S o →
        (Frame.coveredAt S.c.d kk).testBit (bit S o) = true := coveredAtSound hD
    obtain ⟨xh, hbx, hax⟩ := binv_of_agree H C hb.1 hpos hag hun hP'
    -- The bytes an `End` of `s.pc` made `Uninit` that the cache at `s'.pc` doesn't cover leave
    -- the patch set (`ghost_drop_uninit`); the rest stay out of the kept-read liveness.
    obtain ⟨xh2, hbx2, hax2⟩ := ghost_drop_uninit
      (Q := fun o => P' o ∧ s'.pc < S.c.d.insns.size ∧ s'.pc ∈ C.fl.succ[s.pc]! ∧
        C.fl.ends[s.pc]!.bits.testBit (bit S o) = true ∧
        (Frame.coveredAt S.c.d s'.pc).testBit (bit S o) = false) H hbx hax (fun o hq => by
      obtain ⟨ho, hlt, hsu, hend, hcov⟩ := hq
      have hin := (hP' o ho).1
      refine ⟨hin, hendU o ho hin hsu hend, (hP' o ho).2.2.1, fun hc => ?_⟩
      rw [hcv s'.pc o (Nat.le_of_lt hlt) hc hin] at hcov
      cases hcov)
    refine .inl ⟨s', hns, ?_⟩
    unfold DInv
    refine ⟨(fun o => P' o ∧ ¬ (P' o ∧ s'.pc < S.c.d.insns.size ∧ s'.pc ∈ C.fl.succ[s.pc]! ∧
          C.fl.ends[s.pc]!.bits.testBit (bit S o) = true ∧
          (Frame.coveredAt S.c.d s'.pc).testBit (bit S o) = false)), xh2, (And.intro (fun o ho => hP' o ho.1) he' :
        PatchOk S C s' (fun o => P' o ∧ ¬ (P' o ∧ s'.pc < S.c.d.insns.size ∧ s'.pc ∈ C.fl.succ[s.pc]! ∧
          C.fl.ends[s.pc]!.bits.testBit (bit S o) = true ∧
          (Frame.coveredAt S.c.d s'.pc).testBit (bit S o) = false)) ∧ (s'.pc < S.c.d.insns.size → EscSound S C s')), hbx2, hax2,
      fun C' hC' hlt => ?_⟩
    cases hC'
    have hedge : s'.pc ∈ C.fl.succ[s.pc]! ∨ s'.pc ∈ C.fl.pad[s.pc]! := by
      rcases rnext_flow_edge hD C hpre hns with ⟨h1, -⟩ | ⟨h1, -⟩ | h1
      · exact .inl h1
      · exact .inr h1
      · omega
    intro o ho hin
    have hone : KrInv S C s' (fun o' => o' = o) := krInv_next C hkr0 hk (by
      rcases hkill with hpd | hkill
      · refine .inr ⟨hpd, fun o' ho' => ?_⟩
        have e : o' = o := ho'
        rw [e]
        exact hPP o ho.1
      rcases hedge with ht | ht
      · refine .inl ⟨ht, fun o' ho' hin' => ?_⟩
        have e : o' = o := ho'
        rw [e] at hin' ⊢
        refine ⟨hPP o ho.1, hkill o ho.1 hin', ?_⟩
        cases hen : C.fl.ends[s.pc]!.bits.testBit (bit S o) with
        | false => exact .inl rfl
        | true =>
          right
          cases hcb : (Frame.coveredAt S.c.d s'.pc).testBit (bit S o) with
          | true => rfl
          | false => exact absurd ⟨ho.1, hlt, ht, hen, hcb⟩ ho.2
      · refine .inr ⟨ht, fun o' ho' => ?_⟩
        have e : o' = o := ho'
        rw [e]
        exact hPP o ho.1)
    exact hone o rfl hin
  · exact .inr ⟨f, rdone_erase C hpre hd, he⟩

/-- T6: a non-inline body on the ghost (with the cache `S.used k`, for the ghost's `BInv`). -/
theorem dbodySim_noninline (hD : Decodes S code relocs rodata callSites dropped scopes mode)
    (H : Hyps S) {oc : Option (Cert S)} (DH : DHyps S oc) {k p : Nat} {q : Proto} {c' : Cursor}
    {cache' : Cache} {dr' : List DroppedStore} (hP : ProtoFacts S k p q c' cache')
    (hr : ProtoRead S.fr S.ro true S.body p (S.used k) (S.dr k) (S.args k) q c' cache' dr')
    (htable : HdlTables S) (hni : ¬ InlineAt S k) :
    DBodySim S oc k p (S.used k) := by
  have hB := bodySim_noninline_empty hD H hP hr htable hni
  intro s x P xh hs hg hkr hfr ha hrip hci hsafe
  have hbx : BInv S s (xh.jump (addrAt S.ctx (posOf S.r s.pc))) :=
    vt_bInv_used hfr (by rw [hs]; exact hci)
  have hxr : x.rip = addrAt S.ctx p := ha.2.2.2.1.trans hrip
  cases oc with
  | none =>
    have hg' : ∀ o, ¬ P o := hg
    have hx : x = xh := xAgree_none_eq hg' ha
    subst hx
    refine (hB s x hs hfr hrip ⟨_, hbx⟩ hsafe).mono ?_
    rintro x' (⟨s', hn, hb, -⟩ | ⟨f, hd, he⟩)
    · exact .inl ⟨s', hn, dinv_of_binv hb (fun C hC => by cases hC)⟩
    · exact .inr ⟨f, hd, he⟩
  | some C =>
    obtain ⟨hpat, hesc⟩ := hg
    have hkn : s.pc < S.c.d.insns.size := by
      rw [hs]; exact (reducedOf_insns hD.reduced).1 ▸ hP.lt
    have hesc' := hesc hkn
    have hfrE : FrameInvR S (erase s P) x := frameInvR_erase H C hfr ha hpat hesc'
    have hbE : BInv S (erase s P) (xh.jump (addrAt S.ctx (posOf S.r s.pc))) := by
      have h0 := frameInvR_erase H C hfr (xAgree_refl S P xh) hpat hesc'
      have hc0 : CacheInv (S.used (erase s P).pc) (S.virt xh) := by
        show CacheInv (S.used s.pc) (S.virt xh)
        rw [hs]; exact hci
      exact vt_bInv_used h0 hc0
    have hpre := dnoninline_pre hD H C DH rfl hP hni hs hpat hesc' hfr hsafe
    refine (hB (erase s P) x hs hfrE hxr ⟨_, hbE⟩ (rsafe_erase C hpre)).mono ?_
    intro x' hn
    exact dnoninline_next hD H C DH hpre (hkr C rfl hkn) hn

/-- `reducedOf`'s `dropped`: the protos with a dropped store. -/
theorem reducedOf_dropped_eq {r : ReadResult} {pe : Bool} {d : Decoded}
    (h : reducedOf r pe = .ok d) :
    d.dropped = ((List.range r.protos.size).filter (r.protos[·]!.dropped)).toArray := by
  unfold reducedOf at h
  obtain ⟨insns, -, h2⟩ := ebind_ok h
  obtain ⟨head, -, h3⟩ := ebind_ok h2
  cases h3
  rfl

/-- T7: proto `k` with a dropped store is in `d.dropped` (`reducedOf`). -/
theorem mem_dropped_of_proto (hD : Decodes S code relocs rodata callSites dropped scopes mode)
    {k : Nat} (hk : k < S.r.protos.size) (h : S.r.protos[k].dropped = true) :
    k ∈ S.c.d.dropped.toList := by
  rw [reducedOf_dropped_eq hD.reduced]
  have h' : S.r.protos[k]!.dropped = true := by rw [getElem!_pos S.r.protos k hk]; exact h
  simp only [List.toList_toArray, List.mem_filter, List.mem_range]
  exact ⟨hk, h'⟩

/-! ### T6 piece 3, part (a): `execItems_skip`'s side conditions -/

/-- **Open** (DS-T10, image slots apart from the frame): a kept `loadRip` reads an image slot
(`S.ctx.addrOf to`), never a frame byte (`FrameSep`/`CodeApart`/`EnvApart`-style separation of
the image from the frame window). Shared by `execItems_skip` and `keptPtrLive_of_step`. -/
theorem kept_loadRip_apart (H : Hyps S) {oc : Option (Cert S)} (DH : DHyps S oc)
    {s : R.RState} {P : Int → Prop} {yh : X86.State}
    {kept : List Item} (hfr : FrameInv S s yh) (hP : ∀ o, P o → InFrame S o)
    (_hkept : S.c.d.items[s.pc]? = some kept) :
    ∀ it ∈ kept, ∀ r to, it = .loadRip r to → ∀ j < 8, ∀ o, P o →
      S.ctx.addrOf to + BitVec.ofNat 64 j ≠ yh.reg .rbp + BitVec.ofInt 64 o := by
  intro _ _ _ to _ j hj o ho
  have h0 : S.x0.rsp = yh.reg .rbp + 8 := by have := hfr.frame.rbp; bv_omega
  have hw : yh.reg .rbp + BitVec.ofInt 64 o = S.winAddr o := by
    unfold Setup.winAddr
    rw [h0, BitVec.add_sub_cancel]
  have hin := hP o ho
  have hK : (16 : Int) ≤ S.K := by have := H.argSizeK; omega
  rw [hw]
  exact DH.imageOffFrame to j hj o hin.1 (by have := hin.2; omega)

/-- The kept items are among the emitted ones. -/
theorem skipAt_sub {p : Nat} {dr dr' : List DroppedStore} {out kept : List Item}
    (h : SkipAt p dr out kept dr') : ∀ it ∈ kept, it ∈ out := by
  induction h with
  | nil _ _ => intro it hit; cases hit
  | keep _ ih =>
    intro it hit
    rcases List.mem_cons.1 hit with rfl | hit
    · exact List.mem_cons_self ..
    · exact List.mem_cons_of_mem _ (ih it hit)
  | drop _ _ ih => intro it hit; exact List.mem_cons_of_mem _ (ih it hit)

/-- The emitted items of an inline sequence are `cacheSafe` (`CacheStep.emit_safe`). -/
theorem dinline_cacheSafe {f : Full.Opcode} {cls : Class} {ops : List (R.Opnd Nat)}
    {cand : List Item} {br : Option Cond} {cache cache' : Cache} {out : List Item}
    {y : X86.State} (hci : CacheInv cache y) (hmem : (f, cls) ∈ inlineOps)
    (hseq : sequence cls ops = some (cand, br)) (hemit : cache.emit cand = (out, cache')) :
    ∀ it ∈ out, cacheSafe it = true := by
  obtain ⟨-, hext, -⟩ := inline_class_of hmem
  have h := CacheStep.emit_safe hci.1 (fun it hit => (CacheStep.sequence_ok2 hext hseq it hit).1)
  rw [hemit] at h
  exact h

/-- The dropped stores are pure stores (`DroppedForm`, `pureStore_of_form`). -/
theorem dinline_pure {oc : Option (Cert S)} (DH : DHyps S oc) (k : Nat) :
    ∀ d ∈ S.dr k, PureStore S.ctx d.item := fun d hd => pureStore_of_form S.ctx (DH.forms k d hd)

/-- T6 piece 3, step (c): a sequence ending in a `jcc` (no dropped store's item) keeps it last;
the kept items before it are `SkipAt` of the emitted ones. -/
theorem skipAt_snoc {b : Item} : ∀ (out : List Item) {p : Nat} {dr dr' : List DroppedStore}
    {kept : List Item}, SkipAt p dr (out ++ [b]) kept dr' → (∀ d ∈ dr, d.item ≠ b) →
    ∃ kept0, SkipAt p dr out kept0 dr' ∧ kept = kept0 ++ [b]
  | [], p, dr, dr', kept, h, hb => by
    simp only [List.nil_append] at h
    cases h with
    | keep h' =>
      cases h'
      exact ⟨[], .nil p _, rfl⟩
    | drop _ h' =>
      exact absurd rfl (hb _ (List.mem_cons_self ..))
  | x :: out, p, dr, dr', kept, h, hb => by
    simp only [List.cons_append] at h
    cases h with
    | keep h' =>
      obtain ⟨kept0, h0, rfl⟩ := skipAt_snoc out h' hb
      exact ⟨x :: kept0, .keep h0, rfl⟩
    | drop hat h' =>
      obtain ⟨kept0, h0, rfl⟩ :=
        skipAt_snoc out h' (fun d hd => hb d (List.mem_cons_of_mem _ hd))
      exact ⟨kept0, .drop hat h0, rfl⟩

/-- T6 piece 3, step (c): a `DecDrop` read ending in an item no dropped store's is, split before
it: the read of the rest, then that item decoded at the split point. -/
theorem decDrop_snoc {c : Cursor} {b : Item} : ∀ (out : List Item) {p q : Nat}
    {dr dr' : List DroppedStore}, DecDrop c p dr (out ++ [b]) q dr' → (∀ d ∈ dr, d.item ≠ b) →
    ∃ m n, DecDrop c p dr out m dr' ∧ decodeItem (atPos c m) = some (b, n) ∧ q = m + n
  | [], p, q, dr, dr', h, hb => by
    simp only [List.nil_append] at h
    cases h with
    | item hd hrest =>
      cases hrest
      exact ⟨p, _, .nil p _, hd, rfl⟩
    | drop _ _ =>
      exact absurd rfl (hb _ (List.mem_cons_self ..))
  | x :: out, p, q, dr, dr', h, hb => by
    simp only [List.cons_append] at h
    cases h with
    | item hd hrest =>
      obtain ⟨m, n, h0, hdm, hq⟩ := decDrop_snoc out hrest hb
      exact ⟨m, n, .item hd h0, hdm, hq⟩
    | drop hat hrest =>
      obtain ⟨m, n, h0, hdm, hq⟩ :=
        decDrop_snoc out hrest (fun d hd => hb d (List.mem_cons_of_mem _ hd))
      exact ⟨m, n, .drop hat h0, hdm, hq⟩

/-- T6 piece 3, step (c): the `jcc` ending an inline read with dropped stores is canonical where
it is read (`decDrop_snoc`, `branch_canonical_any`). -/
theorem decDrop_branch {c : Cursor} {cond : Cond} {t : BitVec 32} {l : Bool} (out : List Item)
    {p q : Nat} {dr dr' : List DroppedStore} (h : DecDrop c p dr (out ++ [.branch cond t l]) q dr')
    (hb : ∀ d ∈ dr, d.item ≠ .branch cond t l) :
    ∃ m n, DecDrop c p dr out m dr' ∧ decodeItem (atPos c m) = some (.branch cond t l, n) ∧
      q = m + n ∧ (Item.branch cond t l).Canonical m := by
  obtain ⟨m, n, h0, hd, hq⟩ := decDrop_snoc out h hb
  exact ⟨m, n, h0, hd, hq, branch_canonical_any hd⟩

/-- No dropped store is a branch (`DroppedForm`: a store). -/
theorem dropped_ne_branch {oc : Option (Cert S)} (DH : DHyps S oc) (k : Nat) {cond : Cond}
    {t : BitVec 32} {l : Bool} : ∀ d ∈ S.dr k, d.item ≠ .branch cond t l := by
  intro d hd h
  obtain ⟨w, r, off, he⟩ := DH.forms k d hd
  rw [he] at h
  cases h

/-- T6 piece 3, step (c), frame-pointer form: what `inlineInsn`'s read with dropped stores
(`DecDrop`) leaves in memory, with the code bytes it occupies: the kept items (`SkipAt`), in
memory from `p` (`CodeAt`), ending at the read's end, and every byte of them a code byte
(`codeAt_of_decDrop` with `inline_inCode_dec`'s bytes). -/
theorem codeAt_inCode_of_decDrop {ctx : Ctx} {m : X86.Mem} {c : Cursor} {rs : Array Reloc}
    (hk : LinkOk ctx m c rs) :
    ∀ {p q : Nat} {dr dr' : List DroppedStore} {out : List Item}, DecDrop c p dr out q dr' →
      Boundary rs p → ∃ kept, SkipAt p dr out kept dr' ∧ CodeAt ctx m kept p ∧
        q = p + codeSize kept ∧ Boundary rs q ∧
        ∀ a, InCode ctx kept p a → ∃ j, j < c.code.size ∧ a = addrAt ctx j
  | _, _, _, _, _, .nil p dr, hb =>
    ⟨[], .nil p dr, trivial, by simp [codeSize], hb, fun _ h => h.elim⟩
  | _, _, _, _, _, .item (p := p) (n := n) (i := i) hd hrest, hb => by
    obtain ⟨hi, hn, hle, hb'⟩ := decodeItem_itemAt (c := atPos c p) hk.fields hk.sorted hk.loaded
      hk.small hk.fp hb hd
    obtain ⟨kept, hs, hc, hq, hb'', hin⟩ := codeAt_inCode_of_decDrop hk hrest hb'
    refine ⟨i :: kept, .keep (by rw [hn]; exact hs), ⟨hi, by rw [hn]; exact hc⟩, ?_, hb'',
      fun a ha => ?_⟩
    · rw [hq, codeSize_cons, hn, Nat.add_assoc]
    · rcases ha with ⟨j, hj, rfl⟩ | ha
      · rw [inline_linkedAt_length, hn] at hj
        exact ⟨p + j, by simp at hle; omega, addrAt_add' ctx p j⟩
      · rw [hn] at ha
        exact hin a ha
  | _, _, _, _, _, .drop hat hrest, hb => by
    obtain ⟨kept, hs, hc, hq, hb', hin⟩ := codeAt_inCode_of_decDrop hk hrest hb
    exact ⟨kept, .drop hat hs, hc, hq, hb', hin⟩

/-- The kept items are among the emitted ones (`Skip`). -/
theorem skip_sub {dr dr' : List DroppedStore} {out kept : List Item}
    (h : Skip dr out kept dr') : ∀ it ∈ kept, it ∈ out := by
  induction h with
  | nil _ => intro it hit; cases hit
  | keep _ ih =>
    intro it hit
    rcases List.mem_cons.1 hit with rfl | hit
    · exact List.mem_cons_self ..
    · exact List.mem_cons_of_mem _ (ih it hit)
  | drop _ ih => intro it hit; exact List.mem_cons_of_mem _ (ih it hit)

/-- `codeAt_inCode_of_decDrop` in either frame form (`nf_decodeItem_itemAt`): the kept items
are in memory in their `spFrame` form, positions by their sizes there (so `Skip`, not `SkipAt`),
each one an item `decodeItem` read. -/
theorem codeAt_inCode_of_decDropF {ctx : Ctx} {m : X86.Mem} {c : Cursor} {rs : Array Reloc}
    {mode : Ryo.Obj.Mode} (hk : LinkOkF ctx m c rs mode) :
    ∀ {p q : Nat} {dr dr' : List DroppedStore} {out : List Item}, DecDrop c p dr out q dr' →
      Boundary rs p → ∃ kept, Skip dr out kept dr' ∧
        CodeAt ctx m (kept.map (FForm.item c.spFrame)) p ∧
        q = p + codeSize (kept.map (FForm.item c.spFrame)) ∧ Boundary rs q ∧
        (∀ a, InCode ctx (kept.map (FForm.item c.spFrame)) p a →
          ∃ j, j < c.code.size ∧ a = addrAt ctx j) ∧
        ∀ i ∈ kept, ∃ p' n, decodeItem (atPos c p') = some (i, n)
  | _, _, _, _, _, .nil p dr, hb =>
    ⟨[], .nil dr, trivial, by simp [codeSize], hb, fun _ h => h.elim, fun _ h => by cases h⟩
  | _, _, _, _, _, .item (p := p) (n := n) (i := i) hd hrest, hb => by
    obtain ⟨hi, hn, hle, hb'⟩ := nf_decodeItem_itemAt hk hb hd
    obtain ⟨kept, hs, hc, hq, hb'', hin, hdk⟩ := codeAt_inCode_of_decDropF hk hrest hb'
    refine ⟨i :: kept, .keep hs, ⟨hi, by rw [hn]; exact hc⟩, ?_, hb'', fun a ha => ?_, ?_⟩
    · rw [hq, List.map_cons, codeSize_cons, hn, Nat.add_assoc]
    · rw [List.map_cons] at ha
      rcases ha with ⟨j, hj, rfl⟩ | ha
      · rw [inline_linkedAt_length, hn] at hj
        exact ⟨p + j, by omega, addrAt_add' ctx p j⟩
      · rw [hn] at ha
        exact hin a ha
    · intro i' hi'
      rcases List.mem_cons.1 hi' with rfl | hi'
      · exact ⟨p, n, hd⟩
      · exact hdk i' hi'
  | _, _, _, _, _, .drop _ hrest, hb => by
    obtain ⟨kept, hs, hc, hq, hb', hin, hdk⟩ := codeAt_inCode_of_decDropF hk hrest hb
    exact ⟨kept, .drop hs, hc, hq, hb', hin, hdk⟩

/-- T6 piece 3, step (c): the kept items are canonical from every position (they are among
the emitted ones, `CacheStep.emit_wf`). -/
theorem dinline_canon (H : Hyps S) {f : Full.Opcode} {cls : Class} {ops : List (R.Opnd Nat)}
    {cand : List Item} {br : Option Cond} {cache cache' : Cache} {out : List Item}
    {y : X86.State} (hci : CacheInv cache y) (hmem : (f, cls) ∈ inlineOps)
    (hseq : sequence cls ops = some (cand, br)) (hemit : cache.emit cand = (out, cache'))
    {p : Nat} {dr dr' : List DroppedStore} {kept : List Item} (hs : SkipAt p dr out kept dr') :
    ∀ pos, Canon kept pos := by
  have hw := CacheStep.emit_wf hci.1 (CacheStep.sequence_wf (H.inlineClsOk f cls hmem).2 hseq)
  rw [hemit] at hw
  exact CacheStep.canon_of_all (fun i hi => hw i (skipAt_sub hs i hi))

open Ryo.Vm.OpSem Ryo.Proofs.Inline Ryo.Proofs.Scope Ryo.Proofs.ScopeMem Ryo.Proofs.FrameBounds
  Ryo.Proofs.CacheMem in
/-- T6 piece 3, step (c): the kept items' run keeps the code bytes (`inline_fetchRun'` for a
sublist of the emitted items, run from any state `z` with the frame state's `rbp`, the real
machine's included), for a class other than `store`. -/
theorem dinline_fetchRun (H : Hyps S)
    {s s' : R.RState} {x : X86.State} {ch : OpSem.Choice}
    {op : Reduced.Opcode} {ops : List (R.Opnd Nat)} {f : Full.Opcode} {cls : Class}
    {cand : List Item} {br : Option Cond} {cache : Cache}
    (hf : FrameInv S s x) (hci : CacheInv cache x)
    (hi : S.c.d.insns[s.pc]? = some (.native op ops)) (hfull : op.full = some f)
    (hmem : (f, cls) ∈ inlineOps)
    (hseq : sequence cls ops = some (cand, br))
    (hstep : R.step S.c s ch = .ok (.step s')) (hns : ∀ w, cls ≠ .store w)
    {kept : List Item} (hsub : ∀ it ∈ kept, it ∈ (cache.emit cand).1)
    (z : X86.State) (hz : z.reg .rbp = x.reg .rbp) :
    FetchRun S.ctx (fun a => ∃ j, j < S.body.code.size ∧ a = addrAt S.ctx j) kept z := by
  have hcls := H.inlineClsOk
  have hok := H.inlineOk f cls hmem
  have hfb := H.frameBounds
  obtain ⟨-, hext, -⟩ := inline_class_of hmem
  have hsafeC : ∀ it ∈ cand, cacheSafe it = true := fun it hit =>
    (CacheStep.sequence_ok2 hext hseq it hit).1
  have hsafe := CacheStep.emit_safe hci.1 hsafeC
  obtain ⟨s1, hsc, hv⟩ := Step.step_native hi hfull hok.opShape hstep
  obtain ⟨vals, _, _, _, _, hn, _, _, _, _⟩ :=
    Step.stepView_native hfull hok.opShape hok.notResume hok.notUnreachable hv
  have hwin : WrIn (-(S.F : Int)) S.K f vals := hfb.writes s.pc op ops f vals hi hfull hn
  exact
    inline_fetchRun (fun y => y.reg .rbp = x.reg .rbp) (fun e he y y' hy hey => by
      obtain ⟨h1, h2⟩ := CacheStep.exec_writes (hsafe e (hsub e he)) hey
      refine ⟨h1, fun a ha => h2 a (fun m n hw => ?_),
        (CacheStep.exec_rbp (hsafe e (hsub e he)) hey).trans hy⟩
      obtain ⟨it, hit, m', hw', hm⟩ := CacheStep.emit_writes hci.1 e (hsub e he) m n hw
      have hbase : m'.base = .rbp := by
        rcases CacheStep.sequence_writes_frame hseq it hit m' n hw' with h | ⟨w, h⟩
        · exact h
        · exact absurd h (hns w)
      obtain ⟨r, hr, hr1, hr2⟩ :=
        CacheStep.sequence_writes_in (hcls f cls hmem).1 hseq hn it hit m' n hw' hbase
      have hw := hwin r hr
      have hea : y.ea m = fpAddr x m'.disp.toInt := by
        rw [hm, hbase]
        simp only [show (Reg.rbp == Ryo.Vm.Asm.R) = false by decide, Bool.false_eq_true, ↓reduceIte]
        show fpAddr y m'.disp.toInt = _
        simp only [fpAddr, hy]
      obtain ⟨jj, hjj, rfl⟩ := ha
      obtain ⟨-, -, hwa, -⟩ := H.codeApart _ (.inl ⟨jj, hjj, rfl⟩)
      rw [hea]
      apply Nat.le_of_not_lt
      intro hlt
      have e : fpAddr x (m'.disp.toInt + ((addrAt S.ctx jj - fpAddr x m'.disp.toInt).toNat : Nat))
          = addrAt S.ctx jj := by
        rw [fpAddr_add, bv_add_sub_toNat]
      exact hwa (m'.disp.toInt + ((addrAt S.ctx jj - fpAddr x m'.disp.toInt).toNat : Nat))
        (by omega) (by omega) (by rw [← hf.fpAddr_eq]; exact e.symm)) z hz

/-- T6 piece 3, step (c): the kept items, canonical and in memory from `rip`, fetched to their
run's end (`steps_of_run`), which is the read's end `q`. -/
theorem dinline_steps {ctx : Ctx} {Sa : BitVec 64 → Prop} {kept : List Item} {p q : Nat}
    {x x' : X86.State} (hcan : Canon kept p) (hc : CodeAt ctx x.mem kept p)
    (hq : q = p + codeSize kept) (hrip : x.rip = addrAt ctx p)
    (hS : ∀ a, InCode ctx kept p a → Sa a) (hrun : FetchRun ctx Sa kept x)
    (he : execItems ctx kept x = .ok x') :
    Steps ctx x x' ∧ x'.rip = addrAt ctx q ∧ ∀ a, Sa a → x'.mem a = x.mem a := by
  obtain ⟨h1, h2, h3⟩ := steps_of_run hcan hc hrip hS hrun he
  exact ⟨h1, by rw [hq]; exact h2, h3⟩

/-- T6 piece 3, piece 2 (frame-pointer form, no `jcc`, a class other than `store`): the kept
items of an inline read with dropped stores are in the real machine's memory (`LinkOk` there) and
fetched: whatever their run gives, the machine steps to it, `rip` at the read's end, the code
bytes kept, and the read's end a boundary. `xg` is the
frame state the R step runs on (for the kept writes' window), with the real machine's `rbp`. -/
theorem dinline_line_fp (H : Hyps S)
    {s s' : R.RState} {xg : X86.State} {op : Reduced.Opcode} {ops : List (R.Opnd Nat)}
    {f : Full.Opcode} {cls : Class} {cand : List Item} {br : Option Cond} {cache cache' : Cache}
    {out : List Item} (hfg : FrameInv S s xg) (hci : CacheInv cache xg)
    (hi : S.c.d.insns[s.pc]? = some (.native op ops)) (hfull : op.full = some f)
    (hmem : (f, cls) ∈ inlineOps) (hseq : sequence cls ops = some (cand, br))
    (hstep : R.step S.c s {} = .ok (.step s')) (hns : ∀ w, cls ≠ .store w)
    (hemit : cache.emit cand = (out, cache'))
    {p q : Nat} {dr dr' : List DroppedStore} {x : X86.State}
    (hlk : LinkOk S.ctx x.mem S.body S.rs) (hb : Boundary S.rs p)
    (hdd : DecDrop (atPos S.body p) p dr out q dr') (hrip : x.rip = addrAt S.ctx p)
    (hrbp : x.reg .rbp = xg.reg .rbp) :
    Boundary S.rs q ∧ ∃ kept, SkipAt p dr out kept dr' ∧ ∀ x', execItems S.ctx kept x = .ok x' →
      Steps S.ctx x x' ∧ x'.rip = addrAt S.ctx q ∧
        ∀ a, (∃ j, j < S.body.code.size ∧ a = addrAt S.ctx j) → x'.mem a = x.mem a := by
  obtain ⟨kept, hsk, hcode, hq, hbq, hin⟩ := codeAt_inCode_of_decDrop (bs_linkOk_at hlk p) hdd hb
  refine ⟨hbq, kept, hsk, fun x' he => ?_⟩
  have hcan := dinline_canon H hci hmem hseq hemit hsk p
  have hrun := dinline_fetchRun H hfg hci hi hfull hmem hseq hstep hns
    (fun it hit => by rw [hemit]; exact skipAt_sub hsk it hit) x hrbp
  exact dinline_steps hcan hcode hq hrip hin hrun he

/-- T6 piece 3, piece 4b (frame-pointer form, no `jcc`, the `store` class): as `dinline_line_fp`.
The emitted items are `init ++ [j]` (`emit_store_virt`): `init` writes nothing, `j` stores through
a pointer (not `rbp`-based, so no dropped store is it, and it stays kept). `init`'s kept part is
fetched (`steps_of_run`), then `j` (it may write anywhere, but it is the last). -/
theorem dinline_store_fp (H : Hyps S)
    {s s' : R.RState} {xg : X86.State} {op : Reduced.Opcode} {ops : List (R.Opnd Nat)}
    {f : Full.Opcode} {w} {cand : List Item} {br : Option Cond} {cache cache' : Cache}
    {out : List Item} (hfg : FrameInv S s xg) (hci : CacheInv cache xg)
    (hi : S.c.d.insns[s.pc]? = some (.native op ops)) (hfull : op.full = some f)
    (hmem : (f, .store w) ∈ inlineOps) (hseq : sequence (.store w) ops = some (cand, br))
    (hstep : R.step S.c s {} = .ok (.step s')) (hemit : cache.emit cand = (out, cache'))
    {p q : Nat} {dr dr' : List DroppedStore} {x : X86.State}
    (hlk : LinkOk S.ctx x.mem S.body S.rs) (hb : Boundary S.rs p)
    (hdd : DecDrop (atPos S.body p) p dr out q dr') (hrip : x.rip = addrAt S.ctx p)
    (hrbp : x.reg .rbp = xg.reg .rbp)
    (hdf : ∀ d ∈ dr, ∃ w r off, d.item = Item.st w r (X86.M.frame off)) :
    ∃ kept, SkipAt p dr out kept dr' ∧ ∀ x', execItems S.ctx kept x = .ok x' →
      Steps S.ctx x x' ∧ x'.rip = addrAt S.ctx q := by
  obtain ⟨kept, hsk, hcode, hq, -, hin⟩ := codeAt_inCode_of_decDrop (bs_linkOk_at hlk p) hdd hb
  refine ⟨kept, hsk, fun x' he => ?_⟩
  have hcs : ∀ e ∈ out, cacheSafe e = true := dinline_cacheSafe hci hmem hseq hemit
  have hcanK := dinline_canon H hci hmem hseq hemit hsk p
  obtain ⟨init, j, hsplit, hnone, hjm⟩ := CacheStep.emit_store_virt hci.1 hseq
  rw [hemit] at hsplit
  simp only at hsplit
  have hjo : j ∈ out := by rw [hsplit]; simp
  have hjd : ∀ d ∈ dr, d.item ≠ j := by
    intro d hd hdj
    obtain ⟨w', r', off, he'⟩ := hdf d hd
    have hjst : j = Item.st w' r' (X86.M.frame off) := hdj ▸ he'
    subst hjst
    exact hjm _ rfl rfl
  have hsk2 := hsk
  rw [hsplit] at hsk2
  obtain ⟨kept0, hsk0, rfl⟩ := skipAt_snoc init hsk2 hjd
  rw [canon_append] at hcanK
  rw [codeAt_append] at hcode
  rw [execItems_append] at he
  obtain ⟨y, hy, hj⟩ := except_bind_ok he
  have hjx : j.exec S.ctx y = .ok x' := by
    rw [execItems_cons] at hj
    obtain ⟨z, hz, hz'⟩ := except_bind_ok hj
    cases hz'
    exact hz
  have hsub0 : ∀ e ∈ kept0, e ∈ init := skipAt_sub hsk0
  have hrun0 : FetchRun S.ctx (fun a => ∃ j, j < S.body.code.size ∧ a = addrAt S.ctx j) kept0 x :=
    inline_fetchRun (fun _ => True) (fun e he y y' _ hey => by
      have hcse : cacheSafe e = true :=
        hcs e (by rw [hsplit]; exact List.mem_append_left _ (hsub0 e he))
      obtain ⟨h1, h2⟩ := CacheStep.exec_writes hcse hey
      refine ⟨h1, fun a _ => h2 a (fun m n hw => ?_), trivial⟩
      rw [hnone e (hsub0 e he)] at hw
      cases hw) x trivial
  obtain ⟨hs0, hr0, hm0⟩ := steps_of_run hcanK.1 hcode.1 hrip
    (fun a h => hin a ((inCode_append _ _ _ _).2 (.inl h))) hrun0 hy
  have hcj : CodeAt S.ctx y.mem [j] (p + codeSize kept0) :=
    codeAt_of_agree hcode.2 fun a h => hm0 a (hin a ((inCode_append _ _ _ _).2 (.inr h)))
  have hjr := (CacheStep.exec_writes (hcs j hjo) hjx).1
  refine ⟨hs0.tail (.exec j _ hcanK.2.1 hcj.1 hr0 hjx), ?_⟩
  rw [hjr, hr0, ← addrAt_add, hq, codeSize_append, codeSize_cons, codeSize_nil, Nat.add_zero,
    Nat.add_assoc]

/-- A store the decoder consumed marks the instruction dropped (`inlineInsn_consumed`). -/
theorem dinline_consumed_dropped {k : Nat} {cache cache' : Cache} {q : Proto} {c c' : Cursor}
    {dr' : List DroppedStore}
    (hr : (inlineInsn cache (S.dr k) true).run c = .ok (some (q, cache', dr'), c')) :
    ∀ ds, S.dr k = ds ++ dr' → ds ≠ [] → q.dropped = true := by
  intro ds hds hne
  obtain ⟨_, _, _, pre, _, _, hpre, _, hdq, _, _, -⟩ := inlineInsn_consumed hr
  have e : ds = pre := List.append_cancel_right (hds.symm.trans hpre)
  subst e
  exact hdq hne

/-- An inline opcode has one class (`inlineOps` is `classOf`'s graph). -/
theorem inlineOps_cls {f : Full.Opcode} {c : Class} (h : (f, c) ∈ inlineOps) :
    classOf f = some c := by
  simp only [inlineOps, List.mem_filterMap, Option.map_eq_some_iff, Prod.mk.injEq] at h
  obtain ⟨a, -, c', hc', rfl, rfl⟩ := h
  exact hc'

/-- The kept items of a read are the decoder's: `Skip` with the decoder's remainder `dr'`
consumes the decoder's store (at most one: `droppedFormOk`), and erases its occurrence, the only
store of its kind in `out` (`CacheStep.emit_kinds`, `uniqK_spec`). -/
theorem dinline_kept_eq (hD : Decodes S code relocs rodata callSites dropped scopes mode)
    {oc : Option (Cert S)} (DH : DHyps S oc) {k p : Nat} {cache : Cache} {q : Proto}
    {c' : Cursor} {cache' : Cache} {dr' : List DroppedStore} (hP : ProtoFacts S k p q c' cache')
    (hr : (inlineInsn cache (S.dr k) true).run (atPos S.body p) =
      .ok (some (q, cache', dr'), c'))
    {cand : List Item} {br : Option (Cond × Nat)} {out : List Item}
    (hdi : decodeInline cand br = some (q.op, q.ops)) (hemit : cache.emit cand = (out, cache'))
    {kept : List Item} (hs : Skip (S.dr k) out kept dr') : kept = q.items := by
  obtain ⟨cand', br', out', pre, hdi', hemit', hpre, hcons, hdq, -, hitems, herase⟩ :=
    inlineInsn_consumed hr
  obtain ⟨cls, hmem, hseq⟩ := decodeInline_spec hdi
  have hout : out = out' := by
    obtain ⟨cls', hmem', hseq'⟩ := decodeInline_spec hdi'
    have hc : cls' = cls := Option.some.inj ((inlineOps_cls hmem').symm.trans (inlineOps_cls hmem))
    subst hc
    rw [hseq] at hseq'
    have hcc : cand = cand' := (Prod.mk.inj (Option.some.inj hseq')).1
    subst hcc
    rw [hemit] at hemit'
    exact (Prod.mk.inj hemit').1
  subst hout
  by_cases hpn : pre = []
  · subst hpn
    have hk0 : kept = out := skip_none hs (hpre.trans (List.nil_append _))
    rcases hitems with h | ⟨i, d, hd, -, -⟩
    · rw [hk0, h]
    · cases hd
  · obtain ⟨i, d1, hd1, hx, hq⟩ := herase hpn
    have hk := dropForm_mem_dropped hD hP (hdq hpn)
    cases oc with
    | none =>
      exfalso
      have he := DH.none_empty rfl
      have hsz : S.c.d.dropped.size = 0 := by simpa [Array.isEmpty] using he
      have hnil : S.c.d.dropped.toList = [] :=
        List.eq_nil_of_length_eq_zero (by rw [Array.length_toList]; exact hsz)
      rw [hnil] at hk
      cases hk
    | some C =>
      have hlen : pre.length = 1 := hcons.symm.trans (dropForm_consumed_one hD C hP hk)
      obtain ⟨d0, rfl⟩ : ∃ d0, pre = [d0] := by
        rcases pre with _ | ⟨d0, _ | ⟨d2, tl⟩⟩
        · simp at hlen
        · exact ⟨d0, rfl⟩
        · simp only [List.length_cons] at hlen; omega
      rw [List.mem_singleton] at hd1
      subst hd1
      obtain ⟨j, hj, hkj⟩ := skip_one hs d1 (by simpa using hpre)
      obtain ⟨w, r, off, hf⟩ := DH.forms k d1 (by rw [hpre]; simp)
      have hu : CacheStep.uniqK (out.map CacheStep.kd) = true := by
        have := (CacheStep.emit_kinds hseq cache).2
        rw [hemit] at this
        exact this
      have hij : i = j := CacheStep.uniqK_spec out i j hu hx hj (by rw [hf]; rfl)
      rw [hkj, hq, hij]

/-- Items that may follow a store (`st`, `setcc cl`) are `RipFree` and read no memory. -/
theorem tailOk_ripFree (ctx : Ctx) {y : Item} (h : (CacheStep.kd y).2 = true) :
    y.RipFree ctx ∧ NoRead y := by
  cases y <;> simp only [CacheStep.kd, Bool.false_eq_true] at h
  all_goals
    refine ⟨?_, ?_⟩
    · intro s a
      first
        | rfl
        | (cases ‹W› <;> rfl)
        | (simp only [Item.exec, Ryo.Proofs.RegCache.flags_jump]; cases Cond.eval s.flags ‹Cond› <;> rfl)
    · unfold NoRead
      exact ⟨fun _ _ => rfl, fun r to he => by cases he⟩

/-- The items after a consumed dropped store are `RipFree` and read no memory: it is a store
(`DroppedForm`), and per class a sequence's stores come last or before `flagSeq`
(`CacheStep.emit_kinds`, `tailK_spec`). -/
theorem dinline_tail {oc : Option (Cert S)} (DH : DHyps S oc) {k : Nat} {cache cache' : Cache}
    {q : Proto} {dr' : List DroppedStore}
    {cand : List Item} {br : Option (Cond × Nat)} {out : List Item}
    (hdi : decodeInline cand br = some (q.op, q.ops)) (hemit : cache.emit cand = (out, cache')) :
    ∀ ds, S.dr k = ds ++ dr' → ∀ (pre : List Item) (d : DroppedStore) (post : List Item),
      out = pre ++ d.item :: post → d ∈ ds → ∀ it ∈ post, it.RipFree S.ctx ∧ NoRead it := by
  intro ds hds pre d post e hd it hit
  obtain ⟨cls, -, hseq⟩ := decodeInline_spec hdi
  have ht : CacheStep.tailK (out.map CacheStep.kd) = true := by
    have := (CacheStep.emit_kinds hseq cache).1
    rw [hemit] at this
    exact this
  obtain ⟨w, r, off, hf⟩ := DH.forms k d (by rw [hds]; exact List.mem_append_left _ hd)
  rw [e] at ht
  exact tailOk_ripFree S.ctx (CacheStep.tailK_spec pre ht (by rw [hf]; rfl) it hit)

/-- A slot operand of the mapped operands is one of the operands. -/
theorem opnd_slot_of_map {T U : Type} {f : T → U} {ops : List (R.Opnd T)} {s : BitVec 32}
    (h : (ops.map (opndMap f))[1]? = some (.slot s)) : ops[1]? = some (.slot s) := by
  rw [List.getElem?_map] at h
  cases hv : ops[1]? with
  | none => rw [hv] at h; cases h
  | some v =>
    rw [hv] at h
    cases v <;> simp [opndMap] at h ⊢
    all_goals exact h

/-- An overflow op's flag store `mov [o], cl` is never a dropped store
(`droppedFormOk_flagApart`, as in `dropForm_flag`). -/
theorem flag_not_dropped (hD : Decodes S code relocs rodata callSites dropped scopes mode)
    (C : Cert S) {k p : Nat} {cache : Cache} {q : Proto} {c' : Cursor} {cache' : Cache}
    {dr' : List DroppedStore} (hP : ProtoFacts S k p q c' cache')
    (hr : (inlineInsn cache (S.dr k) true).run (atPos S.body p) =
      .ok (some (q, cache', dr'), c'))
    {ds : List DroppedStore} (hds : S.dr k = ds ++ dr') {d : DroppedStore} (hd : d ∈ ds)
    {fo : BitVec 32} (hde : d.item = .st .b .rcx (X86.M.frame fo))
    (hfs0 : Frame.flagSlot S.c.d k = some fo) : False := by
  obtain ⟨_, _, _, pre, _, _, hpre, hcons, hne, hdit, _, _⟩ := inlineInsn_consumed hr
  have hdp : ds = pre := List.append_cancel_right (hds.symm.trans hpre)
  have hd' : d ∈ pre := hdp ▸ hd
  clear hd hds hdp
  have hk := dropForm_mem_dropped hD hP (hne (List.ne_nil_of_mem hd'))
  obtain ⟨sl, n, hst, hfw⟩ := dropForm_agree hD C hP hr hpre hk d hd'
  have hfe : Asm.frameWrite (Item.st .b .rcx (X86.M.frame fo)) = some (X86.M.frame fo, 1) := by
    simp [Asm.frameWrite, X86.M.frame, Ryo.X86.W.bits]
  rw [hde, hfe] at hfw
  simp only [Option.some.injEq, Prod.mk.injEq, X86.M.frame, X86.M.mk.injEq, true_and] at hfw
  obtain ⟨rfl, rfl⟩ := hfw
  rcases droppedFormOk_flagApart (C.hform k hk) hst hfs0 with hap | ⟨w', src, m, hdk, hsrc⟩
  · omega
  · obtain ⟨hdi0, hco0⟩ := dropForm_at hD hP.lt
    obtain ⟨p1, counter, hpk⟩ := hP.proto
    have hpk' : S.r.protos[k]'hP.lt = { q with pos := p1, counter } := by
      rw [Array.getElem?_eq_getElem hP.lt] at hpk; exact Option.some.inj hpk
    rw [hpk'] at hdi0 hco0
    have hq : q.droppedItem = some (.st w' src m) := Option.some.inj (hdi0.symm.trans hdk)
    obtain ⟨d1, hd1, hx⟩ := hdit _ hq
    have hlen : pre.length = 1 := hcons.symm.trans (dropForm_consumed_one hD C hP hk)
    obtain ⟨d0, rfl⟩ : ∃ d0, pre = [d0] := by
      rcases pre with _ | ⟨d0, _ | ⟨d2, tl⟩⟩
      · simp at hlen
      · exact ⟨d0, rfl⟩
      · simp only [List.length_cons] at hlen; omega
    rw [List.mem_singleton] at hd' hd1
    subst hd' hd1
    rw [hde] at hx
    cases hx
    exact hsrc rfl

/-- The items before the consumed dropped store write none of its bytes. Per class: they write
no frame byte (`preB`), but `mov128`'s high half before its low half (apart: `[s + 8, s + 16)`
against `[s, s + 8)`) and an overflow op's result store before its flag store (`preNR`: the
flag store is never the dropped one, `flag_not_dropped`). -/
theorem dinline_pre_apart (hD : Decodes S code relocs rodata callSites dropped scopes mode)
    (H : Hyps S) {oc : Option (Cert S)} (DH : DHyps S oc) {k p : Nat} {cache : Cache} {q : Proto}
    {c' : Cursor} {cache' : Cache} {dr' : List DroppedStore} (hP : ProtoFacts S k p q c' cache')
    (hr : (inlineInsn cache (S.dr k) true).run (atPos S.body p) =
      .ok (some (q, cache', dr'), c'))
    {cand : List Item} {br : Option (Cond × Nat)} {out : List Item}
    (hdi : decodeInline cand br = some (q.op, q.ops)) (hemit : cache.emit cand = (out, cache')) :
    ∀ ds, S.dr k = ds ++ dr' → ∀ (pre : List Item) (d : DroppedStore) (post : List Item),
      out = pre ++ d.item :: post → d ∈ ds → ∀ it ∈ pre, ∀ o, Writes it o →
        ¬ Writes d.item o := by
  intro ds hds pre d post e hd it hit o hw hwd
  obtain ⟨cls, hmem, hseq⟩ := decodeInline_spec hdi
  by_cases hc : cls = .mov128 ∨ CacheStep.isOvf cls = true
  · -- `mov128`: the high half `[s + 8, s + 16)` before the low `[s, s + 8)`; overflow ops: the
    -- result store before the flag store, never the consumed one (`flagApart`)
    obtain ⟨xr, rest, -, hrest, hrel⟩ := CacheStep.emit_rel cache cand
    simp only [hemit] at hrel
    obtain ⟨pre', x', post', hsplit, hpre', hx'⟩ := CacheStep.EmitRel.split pre hrel e
    obtain ⟨it', hit', hrit⟩ := CacheStep.EmitRel.mem' hpre' hit
    obtain ⟨w, r, off, hf⟩ := DH.forms k d (by rw [hds]; exact List.mem_append_left _ hd)
    have hpw : CacheStep.pw it' = true := by
      obtain ⟨m, n, hfw, -, -⟩ := hw
      exact CacheStep.pw_emit hrit (CacheStep.pw_of_fw (by simp [hfw]))
    have hsx : CacheStep.isStB x' = true := by
      rw [← CacheStep.isStB_emit hx', hf] <;> rfl
    rcases hc with rfl | hov
    · -- `mov128`
      obtain ⟨a, b, hb, hcand⟩ := CacheStep.seq_mov128 hseq
      have hB4 : CacheStep.Before cand it' x' := by
        have hB : CacheStep.Before rest it' x' := ⟨pre', post', hsplit, hit'⟩
        rcases hrest with h0 | ⟨w0, m0, h0⟩
        · rw [← h0]; exact hB
        · rw [h0]; exact CacheStep.before_cons_of hB
      rw [hcand] at hB4
      rcases CacheStep.before_cons hB4 with ⟨rfl, -⟩ | hB3
      · simp [CacheStep.pw, Asm.ld] at hpw
      rcases CacheStep.before_cons hB3 with ⟨rfl, -⟩ | hB2
      · simp [CacheStep.pw] at hpw
      rcases CacheStep.before_cons hB2 with ⟨rfl, hx⟩ | hB1
      · rw [List.mem_singleton] at hx
        subst hx
        have hx'' : d.item = ren xr (.st .q Asm.R (X86.M.frame b)) ∨
            ∃ i : Nat, d.item = withRm (ren xr (.st .q Asm.R (X86.M.frame b))) (.reg pool[i]!) :=
          hx'
        obtain ⟨r2, hit2, -⟩ := CacheStep.rel_st_frame hrit
        obtain ⟨r3, hd3, -⟩ := CacheStep.rel_st_frame hx''
        obtain ⟨m, n, hfw, h1, h2⟩ := hw
        obtain ⟨m', n', hfw', h1', h2'⟩ := hwd
        rw [hit2] at hfw
        rw [hd3] at hfw'
        simp [Asm.frameWrite, X86.M.frame, Ryo.X86.W.bits] at hfw hfw'
        obtain ⟨rfl, rfl⟩ := hfw
        obtain ⟨rfl, rfl⟩ := hfw'
        have e8 : (b + 8).toInt = b.toInt + 8 := by
          have := Ryo.Proofs.Inline.toInt_bounds b
          rw [BitVec.toInt_add_of_not_saddOverflow]
          · rfl
          · simp [BitVec.saddOverflow]; omega
        have e8' : (b + 8#32).toInt = b.toInt + 8 := e8
        simp only at h1 h2 h1' h2'
        omega
      rcases CacheStep.before_cons hB1 with ⟨-, hx⟩ | hB0
      · cases hx
      · exact (CacheStep.before_nil hB0).elim
    · -- overflow ops: no frame writer before the result store; the flag store isn't dropped
      have hpn : CacheStep.preNR rest = true := by
        have h0 := CacheStep.seq_preNR hseq hov
        rcases hrest with h1 | ⟨w0, m0, h1⟩
        · rw [h1]; exact h0
        · rw [h1] at h0
          simp only [CacheStep.preNR, Bool.and_eq_true] at h0
          exact h0.2
      cases hnr : CacheStep.isStNR x'
      · -- a store from `rcx`: the flag store
        obtain ⟨w', m', rfl⟩ : ∃ w' m', x' = .st w' .rcx m' := by
          cases x' <;> simp [CacheStep.isStB, CacheStep.isStNR] at hsx hnr
          subst hnr
          exact ⟨_, _, rfl⟩
        have hxr : Item.st w' .rcx m' ∈ rest := by
          rw [hsplit]; exact List.mem_append_right _ (List.mem_cons.2 (.inl rfl))
        have hxm : Item.st w' .rcx m' ∈ cand := by
          rcases hrest with h0 | ⟨w0, m0, h0⟩
          · rw [← h0]; exact hxr
          · rw [h0]; exact List.mem_cons_of_mem _ hxr
        obtain ⟨s, h1, rfl, rfl⟩ := CacheStep.seq_ovf_rcx hseq hov hxm
        obtain ⟨r2, hd2, hr2⟩ := CacheStep.rel_st_frame hx'
        have hde : d.item = .st .b .rcx (X86.M.frame s) := by rw [hd2, hr2 rfl]
        cases oc with
        | none =>
          obtain ⟨_, _, _, pc, _, _, hpc, _, hne, _, _, _⟩ := inlineInsn_consumed hr
          have hdp : ds = pc := List.append_cancel_right (hds.symm.trans hpc)
          subst hdp
          have hk := dropForm_mem_dropped hD hP (hne (List.ne_nil_of_mem hd))
          have he := DH.none_empty rfl
          have hsz : S.c.d.dropped.size = 0 := by simpa [Array.isEmpty] using he
          have hnil : S.c.d.dropped.toList = [] :=
            List.eq_nil_of_length_eq_zero (by rw [Array.length_toList]; exact hsz)
          rw [hnil] at hk
          cases hk
        | some C =>
          refine flag_not_dropped hD C hP hr hds hd hde ?_
          -- the flag slot is `ops[1]`, the `"o"` operand
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
          have hopnds : op.info.operands = Ryo.Proofs.Inline.classOperands cls :=
            (ofFull_operands hof).trans hocls
          have hoc : Ryo.Proofs.Inline.classOperands cls =
              ⟨"d", .slot⟩ :: ⟨"o", .slot⟩ :: [⟨"a", .slot⟩, ⟨"b", .slot⟩] := by
            cases cls <;> simp only [Ryo.Proofs.CacheStep.isOvf, Bool.false_eq_true] at hov <;> rfl
          have h1m : (ops.map (opndMap (posOf S.r)))[1]? = some (.slot s) := by
            rw [hmap']; exact h1
          have h1' := opnd_slot_of_map h1m
          unfold Frame.flagSlot
          rw [hi']
          simp only
          rw [hopnds, hoc]
          rcases ops with _ | ⟨a0, _ | ⟨a1, rest'⟩⟩ <;> simp at h1'
          subst h1'
          simp [List.zip, List.find?]
      · have h0 := CacheStep.preNR_spec pre' (by rw [← hsplit]; exact hpn) hnr it' hit'
        rw [h0] at hpw
        cases hpw
  · have hp : CacheStep.preB out = true := by
      have := CacheStep.emit_preB hseq hc cache
      rw [hemit] at this
      exact this
    obtain ⟨w, r, off, hf⟩ := DH.forms k d (by rw [hds]; exact List.mem_append_left _ hd)
    rw [e] at hp
    have h0 := CacheStep.preB_spec pre hp (by rw [hf]; rfl) it hit
    obtain ⟨m, n, hfw, -, -⟩ := hw
    have h1 := CacheStep.pw_of_fw (it := it) (by simp [hfw])
    rw [h0] at h1
    cases h1

/-- A `cacheSafe` item reads at most 16 bytes. -/
theorem readBytes_le_of_cacheSafe {it : Item} (h : cacheSafe it = true) :
    readBytes it ≤ 2 ^ 32 := by
  have hw : ∀ w : W, w.bits / 8 ≤ 2 ^ 32 := by intro w; cases w <;> decide
  unfold readBytes Frame.itemReadBytes
  split <;> first | exact hw _ | decide | (simp [cacheSafe] at h)

/-- The decoder's facts about an inline
sequence read at `p` with dropped stores, against the emitted items `out` and the kept ones
(`SkipAt`): the kept items are `q.items` (at most one dropped store per sequence: the decoder's
`eraseIdx dropAt` erases one); consuming a dropped store marks `q.dropped`; the items after a
dropped store are `RipFree` and read no memory (an overflow op's `setcc cl` and flag store); and
the items before a dropped store write none of its bytes (the last writer of a byte is kept:
when the result slot is the flag slot, the dropped result store is overwritten by the kept
flag store). From `dinline_kept_eq`, `dinline_consumed_dropped` and `dinline_tail`. -/
theorem dinline_items (hD : Decodes S code relocs rodata callSites dropped scopes mode)
    (H : Hyps S) {oc : Option (Cert S)} (DH : DHyps S oc) {k p : Nat} {cache : Cache}
    {q : Proto} {c' : Cursor} {cache' : Cache} {dr' : List DroppedStore}
    (hP : ProtoFacts S k p q c' cache')
    (hr : (inlineInsn cache (S.dr k) true).run (atPos S.body p) =
      .ok (some (q, cache', dr'), c'))
    {cand : List Item} {br : Option (Cond × Nat)} {out : List Item}
    (hdi : decodeInline cand br = some (q.op, q.ops)) (hemit : cache.emit cand = (out, cache'))
    {kept : List Item} (hs : SkipAt p (S.dr k) out kept dr') :
    kept = q.items ∧ (∀ ds, S.dr k = ds ++ dr' → ds ≠ [] → q.dropped = true) ∧
    (∀ ds, S.dr k = ds ++ dr' → ∀ (pre : List Item) (d : DroppedStore) (post : List Item),
      out = pre ++ d.item :: post → d ∈ ds → ∀ it ∈ post, it.RipFree S.ctx ∧ NoRead it) ∧
    (∀ ds, S.dr k = ds ++ dr' → ∀ (pre : List Item) (d : DroppedStore) (post : List Item),
      out = pre ++ d.item :: post → d ∈ ds → ∀ it ∈ pre, ∀ o, Writes it o →
        ¬ Writes d.item o) := by
  exact ⟨dinline_kept_eq hD DH hP hr hdi hemit hs.toSkip, dinline_consumed_dropped hr,
    dinline_tail DH hdi hemit, dinline_pre_apart hD H DH hP hr hdi hemit⟩

/-- `dinline_items` for a position-free `Skip` (without a frame pointer the
kept items are placed by their sizes in memory, so the read gives no `SkipAt`). -/
theorem dinline_items_free (hD : Decodes S code relocs rodata callSites dropped scopes mode)
    (H : Hyps S) {oc : Option (Cert S)} (DH : DHyps S oc) {k p : Nat} {cache : Cache}
    {q : Proto} {c' : Cursor} {cache' : Cache} {dr' : List DroppedStore}
    (hP : ProtoFacts S k p q c' cache')
    (hr : (inlineInsn cache (S.dr k) true).run (atPos S.body p) =
      .ok (some (q, cache', dr'), c'))
    {cand : List Item} {br : Option (Cond × Nat)} {out : List Item}
    (hdi : decodeInline cand br = some (q.op, q.ops)) (hemit : cache.emit cand = (out, cache'))
    {kept : List Item} (hs : Skip (S.dr k) out kept dr') :
    kept = q.items ∧ (∀ ds, S.dr k = ds ++ dr' → ds ≠ [] → q.dropped = true) ∧
    (∀ ds, S.dr k = ds ++ dr' → ∀ (pre : List Item) (d : DroppedStore) (post : List Item),
      out = pre ++ d.item :: post → d ∈ ds → ∀ it ∈ post, it.RipFree S.ctx ∧ NoRead it) ∧
    (∀ ds, S.dr k = ds ++ dr' → ∀ (pre : List Item) (d : DroppedStore) (post : List Item),
      out = pre ++ d.item :: post → d ∈ ds → ∀ it ∈ pre, ∀ o, Writes it o →
        ¬ Writes d.item o) := by
  exact ⟨dinline_kept_eq hD DH hP hr hdi hemit hs, dinline_consumed_dropped hr,
    dinline_tail DH hdi hemit, dinline_pre_apart hD H DH hP hr hdi hemit⟩

/-- T6 piece 3, part (b): the kept items of inline instruction `s.pc`, run from the real
virtual state `y` agreeing with the ghost's `yh` but at `P`, read no byte of `P`: `rbp`-based
reads by the kept-read invariant (`krInv_hrd`), pointer reads by `keptPtrApart_after_scopes`
(with `keptPtrLive_of_step`, PtrLive, whose premises `hnt`, `hforms`, `hlr`, `hglob`, `hrun`
are passed through). -/
theorem dinline_keptApart (hD : Decodes S code relocs rodata callSites dropped scopes mode)
    (H : Hyps S) (C : Cert S) {s s1 : R.RState} {P : Int → Prop}
    (hnt : ∀ d dr, S.dr s.pc = d :: dr → d.at_ = S.start s.pc →
      sortedContains S.targets (S.start s.pc) = false)
    (hforms : ∀ d ∈ S.dr s.pc, DroppedForm d)
    {y yh : X86.State} {kept : List Item} (hfr : FrameInv S s yh)
    (hci : CacheInv (S.used s.pc) yh) (hP : PatchOk S C s P) (he : EscSound S C s)
    (hI : KrInv S C s P) (hk : s.pc < S.c.d.insns.size) (hpc : s.pc < S.r.protos.size)
    (hin : InlineAt S s.pc) (hkept : S.c.d.items[s.pc]? = some kept)
    (ha : XAgreeAt (yh.reg .rbp) P y yh)
    (hlr : ∀ it ∈ kept, ∀ r to, it = .loadRip r to → ∀ j < 8, ∀ o, P o →
      S.ctx.addrOf to + BitVec.ofNat 64 j ≠ yh.reg .rbp + BitVec.ofInt 64 o)
    (hsc : (S.c.scopesAt s.pc).foldlM R.applyScope s = .ok s1)
    (hglob : Ryo.Proofs.Inline.Globals S.ctx S.c.ρ s1.st yh)
    (hrun : ∀ op ops f, S.c.d.insns[s.pc]? = some (.native op ops) → op.full = some f →
      ∃ vals ch ctl st', Ryo.Proofs.Inline.nativeVals S.c.ρ f ops = some vals ∧
        OpSem.opSem f vals s1.st ch = .ok (ctl, st'))
    (hcs : ∀ it ∈ kept, cacheSafe it = true) (hrb : ∀ it ∈ kept, readBytes it ≤ 2 ^ 32) :
    KeptApart S.ctx (yh.reg .rbp) P kept y := by
  have hy : y.reg .rbp = yh.reg .rbp := by
    show y.regs _ = yh.regs _
    rw [ha.1]
  have hF : (S.c.d.frameSize : Int) ≤ 2 ^ 62 := by
    have h1 := ds_F_lt H
    have h2 : (2 : Nat) ^ 62 = 4611686018427387904 := by decide
    have h3 : (2 : Int) ^ 62 = 4611686018427387904 := by decide
    omega
  have hk' : s.pc < C.fl.succ.size := by rw [flowOf_succ C.hfl, flow_succ_size]; exact hk
  have hrd := krInv_hrd C hI (fun o ho => (hP o ho).1) hF hk' hkept hrb (yh.reg .rbp)
  exact keptApart_of_ptr S.ctx kept y hcs hy hrd
    (keptPtrApart_after_scopes H hfr hP he hI hk hsc
      (keptPtrLive_of_step H hD hnt hforms hfr hci hP he hI hk hpc hin hkept ha hrd hlr hsc
        hglob hrun))

/-- The bytes the real machine and the ghost differ at after an inline sequence: `P` and the
dropped stores' bytes, less what the kept items write (`execItems_skip`). -/
abbrev PNext (P : Int → Prop) (ds : List DroppedStore) (kept : List Item) : Int → Prop :=
  fun o => (P o ∨ DropW ds o) ∧ ¬ KeptW kept o

/-- The bytes of `P1` that `ghost_drop_uninit` takes out at `s'`: `Uninit` in R and in no slot
the cache there covers. -/
abbrev QDrop (S : Setup) (s' : R.RState) (P1 : Int → Prop) : Int → Prop :=
  fun o => P1 o ∧ s'.st.byteAt o = .ok .uninit ∧ ¬ CacheCovers S s'.pc o

/-- The `jcc` the decoder read at `m` is in memory there, on any state that kept the code bytes
(`decodeItem_itemAt`, `codeAt_of_agree`). -/
theorem dinline_branch_at {x x1 : X86.State} {cond : Cond} {tgt : BitVec 32} {long : Bool}
    {m n : Nat} (hlk : LinkOk S.ctx x.mem S.body S.rs) (hbm : Boundary S.rs m)
    (hd : decodeItem (atPos S.body m) = some (.branch cond tgt long, n))
    (hkeep : ∀ a, (∃ j, j < S.body.code.size ∧ a = addrAt S.ctx j) → x1.mem a = x.mem a) :
    ItemAt S.ctx x1.mem (.branch cond tgt long) m ∧ (Item.branch cond tgt long).size = n := by
  have hk := bs_linkOk_at hlk m
  obtain ⟨hi, hn, hle, -⟩ := decodeItem_itemAt (c := atPos S.body m) hk.fields hk.sorted
    hk.loaded hk.small hk.fp hbm hd
  have hc : CodeAt S.ctx x.mem [.branch cond tgt long] m := ⟨hi, trivial⟩
  have hc' := codeAt_of_agree (m' := x1.mem) hc fun a ha => by
    rcases ha with ⟨j, hj, rfl⟩ | ha
    · rw [inline_linkedAt_length, hn] at hj
      exact hkeep _ ⟨m + j, by simp at hle; omega, addrAt_add' S.ctx m j⟩
    · exact ha.elim
  exact ⟨hc'.1, hn⟩

/-- A `store` sequence has no branch condition. -/
theorem sequence_store_br {T : Type} {w : W} {ops : List (R.Opnd T)} {cand : List Item}
    {br : Option Cond} (hseq : sequence (.store w) ops = some (cand, br)) : br = none := by
  simp only [sequence, bind, pure] at hseq
  repeat' (first
    | (obtain ⟨_, hs, hseq⟩ := hseq
       split at hs <;> (try simp only [Option.some.injEq, reduceCtorEq] at hs) <;> (try subst hs))
    | split at hseq)
  all_goals (try simp only [Option.some.injEq, Prod.mk.injEq] at hseq)
  all_goals (try obtain ⟨_, rfl⟩ := hseq)
  all_goals first | rfl | simp_all

/-- `dinline_branch_at` in either frame form (`nf_decodeItem_itemAtN`: a `jcc` has no memory
operand, so it is its own `spFrame` form). -/
theorem dinline_branch_atF {x x1 : X86.State} {cond : Cond} {tgt : BitVec 32} {long : Bool}
    {m n : Nat} (hlk : LinkOkF S.ctx x.mem S.body S.rs S.c.mode) (hbm : Boundary S.rs m)
    (hd : decodeItem (atPos S.body m) = some (.branch cond tgt long, n))
    (hkeep : ∀ a, (∃ j, j < S.body.code.size ∧ a = addrAt S.ctx j) → x1.mem a = x.mem a) :
    ItemAt S.ctx x1.mem (.branch cond tgt long) m ∧ (Item.branch cond tgt long).size = n := by
  obtain ⟨hi, hn, hle, -⟩ := nf_decodeItem_itemAtN hlk hbm hd rfl
  have hc : CodeAt S.ctx x.mem [.branch cond tgt long] m := ⟨hi, trivial⟩
  have hc' := codeAt_of_agree (m' := x1.mem) hc fun a ha => by
    rcases ha with ⟨j, hj, rfl⟩ | ha
    · rw [inline_linkedAt_length, hn] at hj
      exact hkeep _ ⟨m + j, by omega, addrAt_add' S.ctx m j⟩
    · exact ha.elim
  exact ⟨hc'.1, hn⟩

/-- `skipAt_snoc` for `Skip`. -/
theorem skip_snoc {b : Item} : ∀ (out : List Item) {dr dr' : List DroppedStore}
    {kept : List Item}, Skip dr (out ++ [b]) kept dr' → (∀ d ∈ dr, d.item ≠ b) →
    ∃ kept0, Skip dr out kept0 dr' ∧ kept = kept0 ++ [b]
  | [], dr, dr', kept, h, hb => by
    simp only [List.nil_append] at h
    cases h with
    | keep h' =>
      cases h'
      exact ⟨[], .nil _, rfl⟩
    | drop _ =>
      exact absurd rfl (hb _ (List.mem_cons_self ..))
  | x :: out, dr, dr', kept, h, hb => by
    simp only [List.cons_append] at h
    cases h with
    | keep h' =>
      obtain ⟨kept0, h0, rfl⟩ := skip_snoc out h' hb
      exact ⟨x :: kept0, .keep h0, rfl⟩
    | drop h' =>
      obtain ⟨kept0, h0, rfl⟩ :=
        skip_snoc out h' (fun d hd => hb d (List.mem_cons_of_mem _ hd))
      exact ⟨kept0, .drop h0, rfl⟩

/-- A run of `cacheSafe` items falls through: `rip` advances by their size. -/
theorem execItems_rip_safe {ctx : Ctx} : ∀ {items : List Item} {y y' : X86.State},
    (∀ it ∈ items, cacheSafe it = true) → execItems ctx items y = .ok y' →
    y'.rip = y.rip + BitVec.ofNat 64 (codeSize items)
  | [], y, y', _, h => by
    rw [execItems_nil] at h
    cases h
    simp [codeSize]
  | i :: is, y, y', hs, h => by
    rw [execItems_cons] at h
    obtain ⟨z, hz, hrest⟩ := except_bind_ok h
    have h1 := (CacheStep.exec_writes (hs i (List.mem_cons_self ..)) hz).1
    have h2 := execItems_rip_safe (fun it hit => hs it (List.mem_cons_of_mem _ hit)) hrest
    rw [h2, h1, codeSize_cons]
    simp [BitVec.ofNat_add, BitVec.add_assoc]

/-- Without a patch set every run is apart from it. -/
theorem keptApart_none (ctx : Ctx) (fp : BitVec 64) {P : Int → Prop} (hP : ∀ o, ¬ P o) :
    ∀ (kept : List Item) (y : X86.State), KeptApart ctx fp P kept y
  | [], _ => trivial
  | _ :: is, _ =>
    ⟨fun _ _ _ _ o ho => absurd ho (hP o), fun y' _ => keptApart_none ctx fp hP is y'⟩

/-- The patch set lies in the frame. -/
theorem ghostOk_inFrame {oc : Option (Cert S)} {s : R.RState} {P : Int → Prop}
    (hg : GhostOk S oc s P) : ∀ o, P o → InFrame S o := by
  cases oc with
  | none => exact fun o ho => absurd ho (hg o)
  | some C =>
    obtain ⟨hpat, -⟩ := hg
    exact fun o ho => (hpat o ho).1

set_option maxRecDepth 100000 in
open Ryo.Vm.OpSem Ryo.Proofs.Inline Ryo.Proofs.Scope Ryo.Proofs.ScopeMem Ryo.Proofs.FrameBounds
  Ryo.Proofs.CacheMem in
/-- T6 piece 3, frame-pointer form (piece 3 of the assembly): `dinline_machine` with a frame
pointer. The ghost runs the emitted items (`inline_ghost_run`), the real machine the kept ones
(`dinline_line_fp`, `execItems_skip` with `dinline_items`, `kept_loadRip_apart` and
`dinline_keptApart`); the ghost re-jumped to the real `rip` is at `k + 1`'s start with the cache
after. The `jcc` classes and the `store` class are piece 4. -/
theorem dinline_machine_fp (hD : Decodes S code relocs rodata callSites dropped scopes mode)
    (H : Hyps S) {oc : Option (Cert S)} (DH : DHyps S oc) {k p : Nat} {cache : Cache}
    (hcro : CacheRegsOk S cache) (hcu : cache = S.used k) {q : Proto} {c' : Cursor} {cache' : Cache}
    {dr' : List DroppedStore} (hP : ProtoFacts S k p q c' cache')
    (hr : (inlineInsn cache (S.dr k) true).run (atPos S.body p) =
      .ok (some (q, cache', dr'), c')) (hfp : S.c.mode.framePointer = true) :
    ∀ s x P xh, s.pc = k → GhostOk S oc s P → KrOk S oc s P → FrameInvR S s xh →
      XAgree S P x xh → xh.rip = addrAt S.ctx p → CacheInv cache (S.virt xh) →
      RSafe S.Safe S.c s →
      Reach S.ctx S.E (fun x' => ∃ s' xh' ds, R.step S.c s {} = .ok (.step s') ∧
        BInv S s' xh' ∧ S.dr k = ds ++ dr' ∧ (ds ≠ [] → q.dropped = true) ∧
        XAgree S (PNext P ds q.items) x' xh') x := by
  intro s x P xh hs hg hkr hfr ha hrip hci hsafe
  have hsp : S.body.spFrame = none := hfr.1.code.fp hfp
  have hf : FrameInv S s xh := by
    have h := hfr.1
    rw [S.virt_eq hsp] at h
    exact h
  have hci' : CacheInv cache xh := by
    rw [S.virt_eq hsp] at hci
    exact hci
  have hk := hP.lt
  have hkn : s.pc < S.c.d.insns.size := by
    rw [hs]; exact (reducedOf_insns hD.reduced).1 ▸ hk
  -- The read.
  obtain ⟨-, hh, cand, br, out, hdi, hemit, hd, -, -⟩ := inlineInsn_read_drop hr
  obtain ⟨cls, hmem, hseq⟩ := decodeInline_spec hdi
  -- The ghost run.
  have hbi : BInv S s (xh.jump (addrAt S.ctx (posOf S.r s.pc))) :=
    vt_bInv_used hfr (by rw [hs, ← hcu]; exact hci)
  obtain ⟨op, ops, s', y', hi', hfull, hops, hstep, hy', hrr, hcc, -, hbr, hf', hrbp', -⟩ :=
    inline_ghost_run hD H (inlineBelowLink_of H.frameBounds) (inlineEscBounded_of H)
      H.inlineClsOk hP hcro hh hdi hemit hs hf hci' ⟨_, hbi⟩ hsafe
  have hseqR : sequence cls ops = some (cand, br.map (·.1)) := by
    rw [← inline_seq_map (posOf S.r), hops]; exact hseq
  have hcsO : ∀ it ∈ out, cacheSafe it = true := dinline_cacheSafe hci' hmem hseqR hemit
  -- The real machine's code, `rip` and `rbp`.
  have hfx := dinv_shadow H hg hfr ha hkn
  have hlk : LinkOk S.ctx x.mem S.body S.rs := by
    have h := hfx.1.code.toLinkOk hfp
    rw [setup_virt_mem] at h
    exact h
  have hxr : x.rip = addrAt S.ctx p := ha.2.2.2.1.trans hrip
  have hrbp : x.reg .rbp = xh.reg .rbp := by
    show x.regs _ = xh.regs _
    rw [ha.1]
  have hvf : vfp S xh = xh.reg .rbp := by
    unfold vfp
    rw [S.virt_eq hsp]
  have ha' : XAgreeAt (xh.reg .rbp) P x xh := by
    have h := ha
    unfold XAgree at h
    rw [hvf] at h
    exact h
  obtain ⟨p1, counter, hpk⟩ := hP.proto
  have hpk' : S.r.protos[k] = { q with pos := p1, counter } := by
    rw [Array.getElem?_eq_getElem hk] at hpk; exact Option.some.inj hpk
  -- The kept items, as `d.items` has them, and what the kept-read invariant gives of them.
  obtain ⟨-, -, -, -, -, -, hpkI⟩ := dinline_insn H hP hr
  have hkept : S.c.d.items[s.pc]? = some q.items := by
    rw [hs]
    simp [sim_reducedOf_items hD.reduced, hk, hpkI]
  have hlr := kept_loadRip_apart H DH hf (ghostOk_inFrame hg) hkept
  have hin : InlineAt S s.pc := ⟨op, ops, hi', by simp [hfull, classOf_of_mem hmem]⟩
  have hKA : (∀ it ∈ q.items, cacheSafe it = true) → (∀ it ∈ q.items, readBytes it ≤ 2 ^ 32) →
      KeptApart S.ctx (xh.reg .rbp) P q.items x := by
    intro hcs hrb
    cases oc with
    | none => exact keptApart_none _ _ hg _ _
    | some C =>
      obtain ⟨hpat, hesc⟩ := hg
      obtain ⟨s1, hsc, hv⟩ := Step.step_native hi' hfull (H.inlineOk _ _ hmem).opShape hstep
      obtain ⟨vals, -, ctl, st', -, hn, -, hos, -, -⟩ :=
        Step.stepView_native hfull (H.inlineOk _ _ hmem).opShape
          (H.inlineOk _ _ hmem).notResume (H.inlineOk _ _ hmem).notUnreachable hv
      obtain ⟨st0, x0, hg0⟩ := H.globals
      have hglob : Ryo.Proofs.Inline.Globals S.ctx S.c.ρ s1.st xh :=
        afterScopes_globals hg0 hf.rrel hf.mem (H.frameBounds.scope_size s.pc) s1 hsc
      have hrunR : ∀ op' ops' f', S.c.d.insns[s.pc]? = some (.native op' ops') →
          op'.full = some f' → ∃ vals ch ctl st',
            Ryo.Proofs.Inline.nativeVals S.c.ρ f' ops' = some vals ∧
            OpSem.opSem f' vals s1.st ch = .ok (ctl, st') := by
        intro op' ops' f' hi2 hf2
        rw [hi'] at hi2
        cases hi2
        rw [hfull] at hf2
        cases hf2
        exact ⟨vals, {}, ctl, st', hn, hos⟩
      exact dinline_keptApart hD H C
        (fun d dr => DH.emptyNotTarget s.pc (by rw [hs]; exact hk) d dr) (DH.forms s.pc) hf
        (by rw [hs, ← hcu]; exact hci') hpat (hesc hkn) (hkr C rfl hkn) hkn (by rw [hs]; exact hk)
        hin hkept ha' hlr hsc hglob hrunR hcs hrb
  -- The kept run on the real machine against the ghost's run of `out`, for either read.
  have core : ∀ {kept : List Item} {R : X86.State → Prop}, SkipAt p (S.dr k) out kept dr' →
      (∀ x', execItems S.ctx kept x = .ok x' → Steps S.ctx x x' ∧ R x') →
      ∃ ds x', S.dr k = ds ++ dr' ∧ (ds ≠ [] → q.dropped = true) ∧ Steps S.ctx x x' ∧ R x' ∧
        XAgreeAt (xh.reg .rbp) (PNext P ds q.items) x' (y'.jump x'.rip) := by
    intro kept R hsk hrun
    obtain ⟨hkq, hdq, hrf, hdisj⟩ := dinline_items hD H DH hP hr hdi hemit hsk
    subst hkq
    have hcs : ∀ it ∈ q.items, cacheSafe it = true := fun it hit => hcsO it (skipAt_sub hsk it hit)
    have hrb : ∀ it ∈ q.items, readBytes it ≤ 2 ^ 32 := fun it hit =>
      readBytes_le_of_cacheSafe (hcs it hit)
    obtain ⟨ds, x', hds, hx', hag⟩ := execItems_skip S.ctx hsk hcs (dinline_pure DH k) hrf hdisj
      hlr rfl ha' (hKA hcs hrb) hy'
    obtain ⟨hsteps, hR⟩ := hrun x' hx'
    exact ⟨ds, x', hds, hdq ds hds, hsteps, hR, hag⟩
  have hvf' : ∀ a, vfp S (y'.jump a) = xh.reg .rbp := fun a => by
    unfold vfp
    rw [S.virt_eq hsp]
    exact hrbp'
  have hfj : ∀ a, FrameInv S s' (y'.jump a) := fun a => hf'.congr rfl rfl rfl
  have hnext : s'.pc = k + 1 → S.c.inRegion (k + 1) = false := fun h => by
    obtain ⟨p1', ctr', hpq'⟩ := hP.proto
    have h1 := hD.nextBody hs hP.body (.step hstep) hP.lt
      (by rw [(Array.getElem?_eq_some_iff.1 hpq').2]; exact (inline_read_sites hr : q.sites = []))
    rwa [h] at h1
  have hstop : S.c.inRegion (k + 1) = false → S.start (k + 1) = c'.pos := fun h =>
    inline_nop_none (inline_read_bare hr) (hP.nop h)
  rcases hd with ⟨rfl, hdd⟩ | ⟨cond, tgt, long, hbrs, hdd⟩
  · have hpc : s'.pc = k + 1 := by
      have h : s'.pc = s.pc + 1 := hbr
      rw [h, hs]
    by_cases hst : ∃ w, cls = .store w
    · obtain ⟨w, rfl⟩ := hst
      obtain ⟨kept, hsk, hrun⟩ := dinline_store_fp H hf hci' hi' hfull hmem hseqR hstep hemit
        hlk hP.bound hdd hxr hrbp (fun d hd => DH.forms k d hd)
      obtain ⟨ds, x', hds, hdq, hsteps, hxr', hag⟩ := core hsk hrun
      refine Reach.steps hsteps (.done ⟨s', y'.jump x'.rip, ds, hstep, ?_, hds, hdq, ?_⟩)
      · refine bInv_of_sp hsp ⟨hfj _, .inl ⟨?_, ?_⟩⟩
        · show x'.rip = _
          rw [hxr', hpc, hstop (hnext hpc)]
        · rw [hpc, hP.cache (hnext hpc)]
          exact (Ryo.Proofs.RegCache.inv_jump cache' y' x'.rip).2 hcc
      · unfold XAgree
        rw [hvf']
        exact hag
    have hns : ∀ w, cls ≠ .store w := fun w h => hst ⟨w, h⟩
    obtain ⟨-, kept, hsk, hrun⟩ := dinline_line_fp H hf hci' hi' hfull hmem hseqR hstep hns hemit
      hlk hP.bound hdd hxr hrbp
    obtain ⟨ds, x', hds, hdq, hsteps, ⟨hxr', -⟩, hag⟩ := core hsk hrun
    refine Reach.steps hsteps (.done ⟨s', y'.jump x'.rip, ds, hstep, ?_, hds, hdq, ?_⟩)
    · refine bInv_of_sp hsp ⟨hfj _, .inl ⟨?_, ?_⟩⟩
      · show x'.rip = _
        rw [hxr', hpc, hstop (hnext hpc)]
      · rw [hpc, hP.cache (hnext hpc)]
        exact (Ryo.Proofs.RegCache.inv_jump cache' y' x'.rip).2 hcc
    · unfold XAgree
      rw [hvf']
      exact hag
  · -- A `jcc` class: the kept items, then the `jcc` on the real machine.
    subst hbrs
    by_cases hst : ∃ w, cls = .store w
    · obtain ⟨w, rfl⟩ := hst
      exact absurd (sequence_store_br hseqR) (by simp)
    have hns : ∀ w, cls ≠ .store w := fun w h => hst ⟨w, h⟩
    obtain ⟨m, n, hdd0, hdm, hqm, hcanB⟩ := decDrop_branch out hdd (dropped_ne_branch DH k)
    obtain ⟨hbm, kept, hsk, hrun⟩ := dinline_line_fp H hf hci' hi' hfull hmem hseqR hstep hns
      hemit hlk hP.bound hdd0 hxr hrbp
    obtain ⟨ds, x1, hds, hdq, hsteps, ⟨hxr1, hkeep⟩, hag⟩ := core hsk hrun
    obtain ⟨hitem, hbsz⟩ := dinline_branch_at hlk hbm hdm hkeep
    simp only [BrOk, Option.map_some] at hbr
    obtain ⟨neg, t, b, hctl, heval, hpc⟩ := hbr
    have heval' : cond.eval x1.flags = .ok b := by
      rw [hag.2.2.1]
      exact heval
    have hexec : (Item.branch cond tgt long).exec S.ctx x1 = .ok (x1.jump
        (if b then S.ctx.base + tgt.setWidth 64
          else x1.rip + BitVec.ofNat 64 (Item.branch cond tgt long).size)) := by
      cases b <;> simp [Item.exec, State.jump, heval', bind, Except.bind, pure, Except.pure]
    have htgt : posOf S.r t = tgt.toNat :=
      inline_branch_index (inline_targets hdi) hops hctl
    refine Reach.steps hsteps (.step (.exec (Item.branch cond tgt long) m hcanB hitem hxr1 hexec)
      (.done ⟨s', y'.jump (x1.jump (if b then S.ctx.base + tgt.setWidth 64
          else x1.rip + BitVec.ofNat 64 (Item.branch cond tgt long).size)).rip, ds, hstep, ?_,
        hds, hdq, ?_⟩))
    · refine bInv_of_sp hsp ⟨hfj _, ?_⟩
      cases b with
      | false =>
        simp only [Bool.false_eq_true, ↓reduceIte] at hpc ⊢
        refine .inl ⟨?_, ?_⟩
        · show x1.rip + _ = _
          rw [hpc, hs, hstop (hnext (by rw [hpc, hs])), hqm, hxr1, hbsz, ← addrAt_add]
        · rw [hpc, hs, hP.cache (hnext (by rw [hpc, hs]))]
          exact (Ryo.Proofs.RegCache.inv_jump cache' y' _).2 hcc
      | true =>
        simp only [↓reduceIte] at hpc ⊢
        refine .inr ⟨?_, ?_⟩
        · show _ = addrAt S.ctx _
          rw [hpc, htgt]
          simp only [addrAt]
          congr 1
          apply BitVec.eq_of_toNat_eq
          simp
        · rw [hpc]
          have hmemt : posOf S.r t ∈ S.r.protos[k].targets := by
            rw [hpk']
            simp only [Proto.targets, hh, List.append_nil, List.mem_flatMap]
            refine ⟨.target (posOf S.r t), ?_, by simp [Opnd.targetsOf]⟩
            rw [← hops]
            exact List.mem_map_of_mem (nativeCtl_target hctl)
          have := H.cacheTargets k hk _ hmemt
          unfold Setup.used
          rw [ite_eq_left_iff.mpr (fun h => absurd this h)]
          exact CacheInv.empty _
    · unfold XAgree
      rw [hvf']
      exact ⟨hag.1, hag.2.1, hag.2.2.1, rfl, hag.2.2.2.2⟩

set_option maxRecDepth 100000 in
open Ryo.Vm.OpSem Ryo.Proofs.Inline Ryo.Proofs.Scope Ryo.Proofs.ScopeMem Ryo.Proofs.FrameBounds
  Ryo.Proofs.CacheMem in
/-- T6 piece 5: `dinline_machine` without a frame pointer, straight-line classes but `store`.
The real kept items run on the real virtual state `FForm.virtAt (some F) kept x` (`rbp := rsp + F`,
`rip` shifted), fetched in their `spFrame` form (`steps_of_run_fb`); the ghost runs `out` from
its virtual state jumped to that `rip`; after, both are made real again with the entry's `rbp`
(`FForm.real`). The `jcc` and `store` classes are piece 5b. -/
theorem dinline_machine_nofp (hD : Decodes S code relocs rodata callSites dropped scopes mode)
    (H : Hyps S) {oc : Option (Cert S)} (DH : DHyps S oc) {k p : Nat} {cache : Cache}
    (hcro : CacheRegsOk S cache) (hcu : cache = S.used k) {q : Proto} {c' : Cursor} {cache' : Cache}
    {dr' : List DroppedStore} (hP : ProtoFacts S k p q c' cache')
    (hr : (inlineInsn cache (S.dr k) true).run (atPos S.body p) =
      .ok (some (q, cache', dr'), c')) (hfp : S.c.mode.framePointer = false) :
    ∀ s x P xh, s.pc = k → GhostOk S oc s P → KrOk S oc s P → FrameInvR S s xh →
      XAgree S P x xh → xh.rip = addrAt S.ctx p → CacheInv cache (S.virt xh) →
      RSafe S.Safe S.c s →
      Reach S.ctx S.E (fun x' => ∃ s' xh' ds, R.step S.c s {} = .ok (.step s') ∧
        BInv S s' xh' ∧ S.dr k = ds ++ dr' ∧ (ds ≠ [] → q.dropped = true) ∧
        XAgree S (PNext P ds q.items) x' xh') x := by
  intro s x P xh hs hg hkr hfr ha hrip hci hsafe
  obtain ⟨F, hspF⟩ : ∃ F, S.body.spFrame = some F := ⟨_, nf_spFrame_of_nofp hD hfp⟩
  have hvx : ∀ y, S.virt y = FForm.virt (some F) y := fun y => by
    unfold Setup.virt Setup.fb; rw [hspF]
  have hk := hP.lt
  have hkn : s.pc < S.c.d.insns.size := by
    rw [hs]; exact (reducedOf_insns hD.reduced).1 ▸ hk
  obtain ⟨-, hh, cand, br, out, hdi, hemit, hd, -, -⟩ := inlineInsn_read_drop hr
  obtain ⟨cls, hmem, hseq⟩ := decodeInline_spec hdi
  have hrsp : x.rsp = xh.rsp := by simp only [X86.State.rsp, X86.State.reg, ha.1]
  have hrbpx : x.reg .rbp = xh.reg .rbp := by
    show x.regs _ = xh.regs _
    rw [ha.1]
  rcases hd with ⟨rfl, hdd⟩ | ⟨cond, tgt, long, hbrs, hdd⟩
  rotate_left
  · -- A `jcc` class: the kept items, then the `jcc` on the real state.
    subst hbrs
    by_cases hst : ∃ w, cls = .store w
    · obtain ⟨w, rfl⟩ := hst
      exact absurd (sequence_store_br hseq) (by simp)
    have hns : ∀ w, cls ≠ .store w := fun w h => hst ⟨w, h⟩
    have hfx := dinv_shadow H hg hfr ha hkn
    have hlkF : LinkOkF S.ctx x.mem S.body S.rs S.c.mode := by
      have h := hfx.1.code
      rw [setup_virt_mem] at h
      exact h
    obtain ⟨m, n, hdd0, hdm, hqm, hcanB⟩ := decDrop_branch out hdd (dropped_ne_branch DH k)
    have hdd' : DecDrop (atPos S.body p) p (S.dr k) out m dr' := hdd0
    obtain ⟨kept, hsk, hcode, hq, hbm, hin, hdk⟩ := codeAt_inCode_of_decDropF (hlkF.atPos p) hdd'
      hP.bound
    have hspA : (atPos S.body p).spFrame = some F := hspF
    rw [hspA] at hcode hq hin
    have hsub : ∀ it ∈ kept, it ∈ out := skip_sub hsk
    -- The ghost run, from the ghost's virtual state at the real virtual state's `rip`.
    have hfg0 : FrameInv S s ((S.virt xh).jump (FForm.virtAt (some F) kept x).rip) :=
      hfr.1.congr rfl rfl rfl
    have hcg0 : CacheInv cache ((S.virt xh).jump (FForm.virtAt (some F) kept x).rip) :=
      (Ryo.Proofs.RegCache.inv_jump _ _ _).2 hci
    have hbi : BInv S s (xh.jump (addrAt S.ctx (posOf S.r s.pc))) :=
      vt_bInv_used hfr (by rw [hs, ← hcu]; exact hci)
    obtain ⟨op, ops, s', y', hi', hfull, hops, hstep, hy', hrr, hcc, -, hbr, hf', hrbp', hrsp'⟩ :=
      inline_ghost_run hD H (inlineBelowLink_of H.frameBounds) (inlineEscBounded_of H)
        H.inlineClsOk hP hcro hh hdi hemit hs hfg0 hcg0 ⟨_, hbi⟩ hsafe
    have hseqR : sequence cls ops = some (cand, (some cond : Option Cond)) := by
      rw [← inline_seq_map (posOf S.r), hops]; exact hseq
    obtain ⟨-, hext, -⟩ := inline_class_of hmem
    have hemv := CacheStep.emit_virt S.ctx F hci.1 hext (H.inlineClsOk _ _ hmem).2 hseqR
    rw [hemit] at hemv
    have hcsO : ∀ it ∈ out, cacheSafe it = true := dinline_cacheSafe hci hmem hseqR hemit
    obtain ⟨hkq, hdq, hrf, hdisj⟩ := dinline_items_free hD H DH hP hr hdi hemit hsk
    subst hkq
    have hcs : ∀ it ∈ q.items, cacheSafe it = true := fun it hit => hcsO it (hsub it hit)
    have hrb : ∀ it ∈ q.items, readBytes it ≤ 2 ^ 32 := fun it hit =>
      readBytes_le_of_cacheSafe (hcs it hit)
    -- The real virtual state against the ghost's.
    have ha0 : XAgreeAt ((S.virt xh).reg .rbp) P (FForm.virtAt (some F) q.items x)
        ((S.virt xh).jump (FForm.virtAt (some F) q.items x).rip) := by
      obtain ⟨h1, h2, h3, -, h5⟩ := xAgree_virt ha
      rw [hvx x] at h1 h2 h3 h5
      exact ⟨h1, h2, h3, rfl, h5⟩
    obtain ⟨-, -, -, -, -, -, hpkI⟩ := dinline_insn H hP hr
    have hkept : S.c.d.items[s.pc]? = some q.items := by
      rw [hs]
      simp [sim_reducedOf_items hD.reduced, hk, hpkI]
    have hlr := kept_loadRip_apart H DH hfg0 (ghostOk_inFrame hg) hkept
    have hin' : InlineAt S s.pc := ⟨op, ops, hi', by simp [hfull, classOf_of_mem hmem]⟩
    have hKA : KeptApart S.ctx (((S.virt xh).jump (FForm.virtAt (some F) q.items x).rip).reg .rbp)
        P q.items (FForm.virtAt (some F) q.items x) := by
      cases oc with
      | none => exact keptApart_none _ _ hg _ _
      | some C =>
        obtain ⟨hpat, hesc⟩ := hg
        obtain ⟨s1, hsc, hv⟩ := Step.step_native hi' hfull (H.inlineOk _ _ hmem).opShape hstep
        obtain ⟨vals, -, ctl, st', -, hn, -, hos, -, -⟩ :=
          Step.stepView_native hfull (H.inlineOk _ _ hmem).opShape
            (H.inlineOk _ _ hmem).notResume (H.inlineOk _ _ hmem).notUnreachable hv
        obtain ⟨st0, x0, hg0⟩ := H.globals
        have hglob : Ryo.Proofs.Inline.Globals S.ctx S.c.ρ s1.st
            ((S.virt xh).jump (FForm.virtAt (some F) q.items x).rip) :=
          afterScopes_globals hg0 hfg0.rrel hfg0.mem (H.frameBounds.scope_size s.pc) s1 hsc
        have hrunR : ∀ op' ops' f', S.c.d.insns[s.pc]? = some (.native op' ops') →
            op'.full = some f' → ∃ vals ch ctl st',
              Ryo.Proofs.Inline.nativeVals S.c.ρ f' ops' = some vals ∧
              OpSem.opSem f' vals s1.st ch = .ok (ctl, st') := by
          intro op' ops' f' hi2 hf2
          rw [hi'] at hi2
          cases hi2
          rw [hfull] at hf2
          cases hf2
          exact ⟨vals, {}, ctl, st', hn, hos⟩
        exact dinline_keptApart hD H C
          (fun d dr => DH.emptyNotTarget s.pc (by rw [hs]; exact hk) d dr) (DH.forms s.pc) hfg0
          (by rw [hs, ← hcu]; exact hcg0) hpat (hesc hkn) (hkr C rfl hkn) hkn (by rw [hs]; exact hk)
          hin' hkept ha0 hlr hsc hglob hrunR hcs hrb
    obtain ⟨ds, xv', hds, hxv, hag⟩ := execItems_skip_free S.ctx hsk hcs (dinline_pure DH k) hrf
      hdisj hlr rfl ha0 hKA hy'
    -- The real machine fetches the kept items in their `spFrame` form.
    have hsd : ∀ i ∈ q.items, i.SpDispOk F := fun i hi => by
      obtain ⟨p', n, hdi'⟩ := hdk i hi
      exact spDisp_of_decodeItem (H.spDispOk F hspF) rfl hspF hdi'
    have hz : (FForm.virtAt (some F) q.items x).reg .rbp =
        ((S.virt xh).jump (FForm.virtAt (some F) q.items x).rip).reg .rbp := by
      show (FForm.virt (some F) x).reg .rbp = (S.virt xh).reg .rbp
      rw [hvx xh]
      show (x.setReg .rbp (x.rsp + F.setWidth 64)).reg .rbp =
        (xh.setReg .rbp (xh.rsp + F.setWidth 64)).reg .rbp
      rw [X86.State.reg_setReg, X86.State.reg_setReg, hrsp]
    have hrun := dinline_fetchRun H hfg0 hcg0 hi' hfull hmem hseqR hstep hns
      (fun it hit => by rw [hemit]; exact hsub it hit) _ hz
    obtain ⟨hsteps, hxvr, hkeep⟩ := steps_of_run_fb (fb := some F) (items := q.items) (pos := p)
      (x := x) (xv' := xv')
      (fun i hi => (hemv i (hsub i hi)).1)
      (fun F' hF' => by
        obtain rfl := Option.some.inj hF'
        exact hsd)
      (fun i hi => (hemv i (hsub i hi)).2.1) (fun i hi => (hemv i (hsub i hi)).2.2.1)
      (CacheStep.canon_map_of (fun i hi => (hemv i (hsub i hi)).2.2.2) p)
      hcode (ha.2.2.2.1.trans hrip) hin hrun hxv
    -- The ghost after, made real with the entry's `rbp`.
    have e1 : y'.rsp + F.setWidth 64 = y'.reg .rbp := by
      rw [hrbp', hrsp']
      show (S.virt xh).rsp + F.setWidth 64 = (S.virt xh).reg .rbp
      rw [hvx xh]
      show (xh.setReg .rbp (xh.rsp + F.setWidth 64)).rsp + F.setWidth 64 =
        (xh.setReg .rbp (xh.rsp + F.setWidth 64)).reg .rbp
      rw [FForm.rsp_setReg_rbp, X86.State.reg_setReg]
    have hvh : S.virt ((y'.jump xv'.rip).setReg .rbp (xh.reg .rbp)) = y'.jump xv'.rip := by
      rw [hvx]
      show ((y'.jump xv'.rip).setReg .rbp (xh.reg .rbp)).setReg .rbp
        (((y'.jump xv'.rip).setReg .rbp (xh.reg .rbp)).rsp + F.setWidth 64) = y'.jump xv'.rip
      rw [FForm.rsp_setReg_rbp, FForm.setReg_setReg,
        show (y'.jump xv'.rip).rsp + F.setWidth 64 = (y'.jump xv'.rip).reg .rbp from e1,
        X86.State.setReg_reg_self]
    have hr1 : xv'.regs = y'.regs := hag.1
    have e2 : xv'.rsp + F.setWidth 64 = xv'.reg .rbp := by
      have h := e1
      simp only [X86.State.rsp, X86.State.reg] at h ⊢
      rw [hr1]
      exact h
    have hvR : S.virt (FForm.real (some F) (x.reg .rbp) xv') = xv' := by
      rw [hvx]
      show (xv'.setReg .rbp (x.reg .rbp)).setReg .rbp
        ((xv'.setReg .rbp (x.reg .rbp)).rsp + F.setWidth 64) = xv'
      rw [FForm.rsp_setReg_rbp, FForm.setReg_setReg, e2, X86.State.setReg_reg_self]
    -- The `jcc` on the real state.
    have hxR : (FForm.real (some F) (x.reg .rbp) xv').rip = addrAt S.ctx m := by
      show xv'.rip = _
      rw [hxvr, hq]
    obtain ⟨hitem, hbsz⟩ := dinline_branch_atF (x1 := FForm.real (some F) (x.reg .rbp) xv') hlkF
      hbm hdm hkeep
    simp only [BrOk, Option.map_some] at hbr
    obtain ⟨neg, t, b, hctl, heval, hpc⟩ := hbr
    have heval' : cond.eval (FForm.real (some F) (x.reg .rbp) xv').flags = .ok b := by
      show cond.eval xv'.flags = _
      rw [hag.2.2.1]
      exact heval
    have hexec : (Item.branch cond tgt long).exec S.ctx (FForm.real (some F) (x.reg .rbp) xv') =
        .ok ((FForm.real (some F) (x.reg .rbp) xv').jump
          (if b then S.ctx.base + tgt.setWidth 64
            else (FForm.real (some F) (x.reg .rbp) xv').rip +
              BitVec.ofNat 64 (Item.branch cond tgt long).size)) := by
      cases b <;> simp [Item.exec, State.jump, heval', bind, Except.bind, pure, Except.pure]
    have htgt : posOf S.r t = tgt.toNat := inline_branch_index (inline_targets hdi) hops hctl
    generalize hA : (if b then S.ctx.base + tgt.setWidth 64
        else (FForm.real (some F) (x.reg .rbp) xv').rip +
          BitVec.ofNat 64 (Item.branch cond tgt long).size) = A at hexec
    -- The ghost after, made real with the entry's `rbp`, at the real `rip`.
    have hvh : S.virt ((y'.jump A).setReg .rbp (xh.reg .rbp)) = y'.jump A := by
      rw [hvx]
      show ((y'.jump A).setReg .rbp (xh.reg .rbp)).setReg .rbp
        (((y'.jump A).setReg .rbp (xh.reg .rbp)).rsp + F.setWidth 64) = y'.jump A
      rw [FForm.rsp_setReg_rbp, FForm.setReg_setReg,
        show (y'.jump A).rsp + F.setWidth 64 = (y'.jump A).reg .rbp from e1,
        X86.State.setReg_reg_self]
    have hvR2 : S.virt ((FForm.real (some F) (x.reg .rbp) xv').jump A) = xv'.jump A := by
      rw [setup_virt_jump, hvR]
    have hregs : ((FForm.real (some F) (x.reg .rbp) xv').jump A).regs =
        ((y'.jump A).setReg .rbp (xh.reg .rbp)).regs := by
      show (xv'.setReg .rbp (x.reg .rbp)).regs = ((y'.jump A).setReg .rbp (xh.reg .rbp)).regs
      rw [hrbpx]
      show (fun i => if i = X86.Reg.rbp.idx then xh.reg .rbp else xv'.regs i) =
        (fun i => if i = X86.Reg.rbp.idx then xh.reg .rbp else (y'.jump A).regs i)
      exact congrArg (fun r : Fin 16 → BitVec 64 => fun i =>
        if i = X86.Reg.rbp.idx then xh.reg .rbp else r i) hr1
    have hnext : s'.pc = k + 1 → S.c.inRegion (k + 1) = false := fun h => by
      obtain ⟨p1', ctr', hpq'⟩ := hP.proto
      have h1 := hD.nextBody hs hP.body (.step hstep) hP.lt
        (by rw [(Array.getElem?_eq_some_iff.1 hpq').2]; exact (inline_read_sites hr : q.sites = []))
      rwa [h] at h1
    have hstop : S.c.inRegion (k + 1) = false → S.start (k + 1) = c'.pos := fun h =>
      inline_nop_none (inline_read_bare hr) (hP.nop h)
    obtain ⟨p1, counter, hpk⟩ := hP.proto
    have hpk' : S.r.protos[k] = { q with pos := p1, counter } := by
      rw [Array.getElem?_eq_getElem hk] at hpk; exact Option.some.inj hpk
    refine Reach.steps hsteps (.step (.exec (Item.branch cond tgt long) m hcanB hitem hxR hexec)
      (.done ⟨s', (y'.jump A).setReg .rbp (xh.reg .rbp), ds, hstep,
        ⟨⟨by rw [hvh]; exact hf'.congr rfl rfl rfl,
          fun h => (X86.State.reg_setReg _ .rbp (xh.reg .rbp)).trans (hfr.2 h)⟩, ?_⟩,
        hds, hdq ds hds, ?_⟩))
    · rw [hvh]
      subst hA
      cases b with
      | false =>
        simp only [Bool.false_eq_true, ↓reduceIte] at hpc ⊢
        refine .inl ⟨?_, ?_⟩
        · show (FForm.real (some F) (x.reg .rbp) xv').rip + _ = _
          rw [hpc, hs, hstop (hnext (by rw [hpc, hs])), hqm, hxR, hbsz, ← addrAt_add]
        · rw [hpc, hs, hP.cache (hnext (by rw [hpc, hs]))]
          exact (Ryo.Proofs.RegCache.inv_jump cache' y' _).2 hcc
      | true =>
        simp only [↓reduceIte] at hpc ⊢
        refine .inr ⟨?_, ?_⟩
        · show S.ctx.base + tgt.setWidth 64 = addrAt S.ctx (posOf S.r s'.pc)
          rw [hpc, htgt]
          simp only [addrAt]
          congr 1
          apply BitVec.eq_of_toNat_eq
          simp
        · rw [hpc]
          have hmemt : posOf S.r t ∈ S.r.protos[k].targets := by
            rw [hpk']
            simp only [Proto.targets, hh, List.append_nil, List.mem_flatMap]
            refine ⟨.target (posOf S.r t), ?_, by simp [Opnd.targetsOf]⟩
            rw [← hops]
            exact List.mem_map_of_mem (nativeCtl_target hctl)
          have := H.cacheTargets k hk _ hmemt
          unfold Setup.used
          rw [ite_eq_left_iff.mpr (fun h => absurd this h)]
          exact CacheInv.empty _
    · refine xAgree_of_virt hregs ?_
      rw [hvR2, hvh]
      have hv : vfp S ((y'.jump A).setReg .rbp (xh.reg .rbp)) =
          ((S.virt xh).jump (FForm.virtAt (some F) q.items x).rip).reg .rbp := by
        unfold vfp
        rw [hvh]
        exact hrbp'
      rw [hv]
      exact ⟨hag.1, hag.2.1, hag.2.2.1, rfl, hag.2.2.2.2⟩
  by_cases hst : ∃ w, cls = .store w
  · obtain ⟨w, rfl⟩ := hst
    have hfx := dinv_shadow H hg hfr ha hkn
    have hlkF : LinkOkF S.ctx x.mem S.body S.rs S.c.mode := by
      have h := hfx.1.code
      rw [setup_virt_mem] at h
      exact h
    have hdd' : DecDrop (atPos S.body p) p (S.dr k) out c'.pos dr' := hdd
    obtain ⟨kept, hsk, hcode, hq, -, hin, hdk⟩ := codeAt_inCode_of_decDropF (hlkF.atPos p) hdd'
      hP.bound
    have hspA : (atPos S.body p).spFrame = some F := hspF
    rw [hspA] at hcode hq hin
    have hsub : ∀ it ∈ kept, it ∈ out := skip_sub hsk
    -- The ghost run, from the ghost's virtual state at the real virtual state's `rip`.
    have hfg0 : FrameInv S s ((S.virt xh).jump (FForm.virtAt (some F) kept x).rip) :=
      hfr.1.congr rfl rfl rfl
    have hcg0 : CacheInv cache ((S.virt xh).jump (FForm.virtAt (some F) kept x).rip) :=
      (Ryo.Proofs.RegCache.inv_jump _ _ _).2 hci
    have hbi : BInv S s (xh.jump (addrAt S.ctx (posOf S.r s.pc))) :=
      vt_bInv_used hfr (by rw [hs, ← hcu]; exact hci)
    obtain ⟨op, ops, s', y', hi', hfull, hops, hstep, hy', hrr, hcc, -, hbr, hf', hrbp', hrsp'⟩ :=
      inline_ghost_run hD H (inlineBelowLink_of H.frameBounds) (inlineEscBounded_of H)
        H.inlineClsOk hP hcro hh hdi hemit hs hfg0 hcg0 ⟨_, hbi⟩ hsafe
    have hseqR : sequence (.store w) ops = some (cand, (none : Option Cond)) := by
      rw [← inline_seq_map (posOf S.r), hops]; exact hseq
    obtain ⟨-, hext, -⟩ := inline_class_of hmem
    have hemv := CacheStep.emit_virt S.ctx F hci.1 hext (H.inlineClsOk _ _ hmem).2 hseqR
    rw [hemit] at hemv
    have hcsO : ∀ it ∈ out, cacheSafe it = true := dinline_cacheSafe hci hmem hseqR hemit
    obtain ⟨hkq, hdq, hrf, hdisj⟩ := dinline_items_free hD H DH hP hr hdi hemit hsk
    subst hkq
    have hcs : ∀ it ∈ q.items, cacheSafe it = true := fun it hit => hcsO it (hsub it hit)
    have hrb : ∀ it ∈ q.items, readBytes it ≤ 2 ^ 32 := fun it hit =>
      readBytes_le_of_cacheSafe (hcs it hit)
    -- The real virtual state against the ghost's.
    have ha0 : XAgreeAt ((S.virt xh).reg .rbp) P (FForm.virtAt (some F) q.items x)
        ((S.virt xh).jump (FForm.virtAt (some F) q.items x).rip) := by
      obtain ⟨h1, h2, h3, -, h5⟩ := xAgree_virt ha
      rw [hvx x] at h1 h2 h3 h5
      exact ⟨h1, h2, h3, rfl, h5⟩
    obtain ⟨-, -, -, -, -, -, hpkI⟩ := dinline_insn H hP hr
    have hkept : S.c.d.items[s.pc]? = some q.items := by
      rw [hs]
      simp [sim_reducedOf_items hD.reduced, hk, hpkI]
    have hlr := kept_loadRip_apart H DH hfg0 (ghostOk_inFrame hg) hkept
    have hin' : InlineAt S s.pc := ⟨op, ops, hi', by simp [hfull, classOf_of_mem hmem]⟩
    have hKA : KeptApart S.ctx (((S.virt xh).jump (FForm.virtAt (some F) q.items x).rip).reg .rbp)
        P q.items (FForm.virtAt (some F) q.items x) := by
      cases oc with
      | none => exact keptApart_none _ _ hg _ _
      | some C =>
        obtain ⟨hpat, hesc⟩ := hg
        obtain ⟨s1, hsc, hv⟩ := Step.step_native hi' hfull (H.inlineOk _ _ hmem).opShape hstep
        obtain ⟨vals, -, ctl, st', -, hn, -, hos, -, -⟩ :=
          Step.stepView_native hfull (H.inlineOk _ _ hmem).opShape
            (H.inlineOk _ _ hmem).notResume (H.inlineOk _ _ hmem).notUnreachable hv
        obtain ⟨st0, x0, hg0⟩ := H.globals
        have hglob : Ryo.Proofs.Inline.Globals S.ctx S.c.ρ s1.st
            ((S.virt xh).jump (FForm.virtAt (some F) q.items x).rip) :=
          afterScopes_globals hg0 hfg0.rrel hfg0.mem (H.frameBounds.scope_size s.pc) s1 hsc
        have hrunR : ∀ op' ops' f', S.c.d.insns[s.pc]? = some (.native op' ops') →
            op'.full = some f' → ∃ vals ch ctl st',
              Ryo.Proofs.Inline.nativeVals S.c.ρ f' ops' = some vals ∧
              OpSem.opSem f' vals s1.st ch = .ok (ctl, st') := by
          intro op' ops' f' hi2 hf2
          rw [hi'] at hi2
          cases hi2
          rw [hfull] at hf2
          cases hf2
          exact ⟨vals, {}, ctl, st', hn, hos⟩
        exact dinline_keptApart hD H C
          (fun d dr => DH.emptyNotTarget s.pc (by rw [hs]; exact hk) d dr) (DH.forms s.pc) hfg0
          (by rw [hs, ← hcu]; exact hcg0) hpat (hesc hkn) (hkr C rfl hkn) hkn (by rw [hs]; exact hk)
          hin' hkept ha0 hlr hsc hglob hrunR hcs hrb
    obtain ⟨ds, xv', hds, hxv, hag⟩ := execItems_skip_free S.ctx hsk hcs (dinline_pure DH k) hrf
      hdisj hlr rfl ha0 hKA hy'
    -- The real machine fetches the kept items in their `spFrame` form.
    have hsd : ∀ i ∈ q.items, i.SpDispOk F := fun i hi => by
      obtain ⟨p', n, hdi'⟩ := hdk i hi
      exact spDisp_of_decodeItem (H.spDispOk F hspF) rfl hspF hdi'
    -- The emitted items are `init ++ [j]`, `j` the pointer store (`emit_store_virt`); it is kept.
    obtain ⟨init, j, hsplit, hnone, hjm⟩ := CacheStep.emit_store_virt hci.1 hseqR
    rw [hemit] at hsplit
    simp only at hsplit
    have hjd : ∀ d ∈ S.dr k, d.item ≠ j := by
      intro d hd hdj
      obtain ⟨w', r', off, he'⟩ := DH.forms k d hd
      have hjst : j = Item.st w' r' (X86.M.frame off) := hdj ▸ he'
      subst hjst
      exact hjm _ rfl rfl
    have hsk2 := hsk
    rw [hsplit] at hsk2
    obtain ⟨kept0, hsk0, hkeq⟩ := skip_snoc init hsk2 hjd
    have hsub0 : ∀ e ∈ kept0, e ∈ init := skip_sub hsk0
    have hrun0 : FetchRun S.ctx (fun a => ∃ j, j < S.body.code.size ∧ a = addrAt S.ctx j) kept0
        (FForm.virtAt (some F) (kept0 ++ [j]) x) :=
      inline_fetchRun (fun _ => True) (fun e he y y' _ hey => by
        have hcse : cacheSafe e = true :=
          hcsO e (by rw [hsplit]; exact List.mem_append_left _ (hsub0 e he))
        obtain ⟨h1, h2⟩ := CacheStep.exec_writes hcse hey
        refine ⟨h1, fun a _ => h2 a (fun m n hw => ?_), trivial⟩
        rw [hnone e (hsub0 e he)] at hw
        cases hw) _ trivial
    have hmemK : ∀ i ∈ kept0 ++ [j], i ∈ out := by rw [← hkeq]; exact hsub
    have hmem0 : ∀ i ∈ kept0, i ∈ out := fun i hi => hmemK i (List.mem_append_left _ hi)
    have hcsK : ∀ it ∈ kept0 ++ [j], cacheSafe it = true := fun it hit => hcsO it (hmemK it hit)
    rw [hkeq] at hcode hin hxv hsd hq
    have hsteps := steps_of_run_last_fb (fb := some F) (items := kept0) (j := j) (pos := p)
      (x := x) (xv' := xv')
      (fun i hi => (hemv i (hmemK i hi)).1)
      (fun F' hF' => by
        obtain rfl := Option.some.inj hF'
        exact hsd)
      (fun i hi => (hemv i (hmem0 i hi)).2.1) hjm
      (fun i hi => (hemv i (hmem0 i hi)).2.2.1)
      (CacheStep.canon_map_of (fun i hi => (hemv i (hmemK i hi)).2.2.2) p)
      hcode (ha.2.2.2.1.trans hrip) hin hrun0 hxv
    have hxvr : xv'.rip = addrAt S.ctx (p + codeSize ((kept0 ++ [j]).map (FForm.item (some F)))) := by
      rw [execItems_rip_safe hcsK hxv]
      show x.rip + FForm.delta (some F) (kept0 ++ [j]) + _ = _
      rw [ha.2.2.2.1.trans hrip, FForm.delta, BitVec.add_assoc, BitVec.sub_add_cancel, addrAt_add']
    -- The ghost after, made real with the entry's `rbp`.
    have e1 : y'.rsp + F.setWidth 64 = y'.reg .rbp := by
      rw [hrbp', hrsp']
      show (S.virt xh).rsp + F.setWidth 64 = (S.virt xh).reg .rbp
      rw [hvx xh]
      show (xh.setReg .rbp (xh.rsp + F.setWidth 64)).rsp + F.setWidth 64 =
        (xh.setReg .rbp (xh.rsp + F.setWidth 64)).reg .rbp
      rw [FForm.rsp_setReg_rbp, X86.State.reg_setReg]
    have hvh : S.virt ((y'.jump xv'.rip).setReg .rbp (xh.reg .rbp)) = y'.jump xv'.rip := by
      rw [hvx]
      show ((y'.jump xv'.rip).setReg .rbp (xh.reg .rbp)).setReg .rbp
        (((y'.jump xv'.rip).setReg .rbp (xh.reg .rbp)).rsp + F.setWidth 64) = y'.jump xv'.rip
      rw [FForm.rsp_setReg_rbp, FForm.setReg_setReg,
        show (y'.jump xv'.rip).rsp + F.setWidth 64 = (y'.jump xv'.rip).reg .rbp from e1,
        X86.State.setReg_reg_self]
    have hr1 : xv'.regs = y'.regs := hag.1
    have e2 : xv'.rsp + F.setWidth 64 = xv'.reg .rbp := by
      have h := e1
      simp only [X86.State.rsp, X86.State.reg] at h ⊢
      rw [hr1]
      exact h
    have hvR : S.virt (FForm.real (some F) (x.reg .rbp) xv') = xv' := by
      rw [hvx]
      show (xv'.setReg .rbp (x.reg .rbp)).setReg .rbp
        ((xv'.setReg .rbp (x.reg .rbp)).rsp + F.setWidth 64) = xv'
      rw [FForm.rsp_setReg_rbp, FForm.setReg_setReg, e2, X86.State.setReg_reg_self]
    have hregs : (FForm.real (some F) (x.reg .rbp) xv').regs =
        ((y'.jump xv'.rip).setReg .rbp (xh.reg .rbp)).regs := by
      show (xv'.setReg .rbp (x.reg .rbp)).regs = ((y'.jump xv'.rip).setReg .rbp (xh.reg .rbp)).regs
      rw [hrbpx]
      show (fun i => if i = X86.Reg.rbp.idx then xh.reg .rbp else xv'.regs i) =
        (fun i => if i = X86.Reg.rbp.idx then xh.reg .rbp else (y'.jump xv'.rip).regs i)
      exact congrArg (fun r : Fin 16 → BitVec 64 => fun i =>
        if i = X86.Reg.rbp.idx then xh.reg .rbp else r i) hr1
    have hpc : s'.pc = k + 1 := by
      have h : s'.pc = s.pc + 1 := hbr
      rw [h, hs]
    have hnext : s'.pc = k + 1 → S.c.inRegion (k + 1) = false := fun h => by
      obtain ⟨p1', ctr', hpq'⟩ := hP.proto
      have h1 := hD.nextBody hs hP.body (.step hstep) hP.lt
        (by rw [(Array.getElem?_eq_some_iff.1 hpq').2]; exact (inline_read_sites hr : q.sites = []))
      rwa [h] at h1
    have hstop : S.c.inRegion (k + 1) = false → S.start (k + 1) = c'.pos := fun h =>
      inline_nop_none (inline_read_bare hr) (hP.nop h)
    refine Reach.steps hsteps (.done ⟨s', (y'.jump xv'.rip).setReg .rbp (xh.reg .rbp), ds, hstep,
      ⟨⟨by rw [hvh]; exact hf'.congr rfl rfl rfl,
        fun h => (X86.State.reg_setReg _ .rbp (xh.reg .rbp)).trans (hfr.2 h)⟩, .inl ⟨?_, ?_⟩⟩,
      hds, hdq ds hds, ?_⟩)
    · show xv'.rip = _
      rw [hxvr, hpc, hstop (hnext hpc), hq]
    · rw [hvh, hpc, hP.cache (hnext hpc)]
      exact (Ryo.Proofs.RegCache.inv_jump cache' y' xv'.rip).2 hcc
    · refine xAgree_of_virt hregs ?_
      rw [hvR, hvh]
      have hv : vfp S ((y'.jump xv'.rip).setReg .rbp (xh.reg .rbp)) =
          ((S.virt xh).jump (FForm.virtAt (some F) q.items x).rip).reg .rbp := by
        unfold vfp
        rw [hvh]
        exact hrbp'
      rw [hv]
      exact hag
  have hns : ∀ w, cls ≠ .store w := fun w h => hst ⟨w, h⟩
  -- The real machine's code: the kept items in their `spFrame` form.
  have hfx := dinv_shadow H hg hfr ha hkn
  have hlkF : LinkOkF S.ctx x.mem S.body S.rs S.c.mode := by
    have h := hfx.1.code
    rw [setup_virt_mem] at h
    exact h
  have hdd' : DecDrop (atPos S.body p) p (S.dr k) out c'.pos dr' := hdd
  obtain ⟨kept, hsk, hcode, hq, -, hin, hdk⟩ := codeAt_inCode_of_decDropF (hlkF.atPos p) hdd'
    hP.bound
  have hspA : (atPos S.body p).spFrame = some F := hspF
  rw [hspA] at hcode hq hin
  have hsub : ∀ it ∈ kept, it ∈ out := skip_sub hsk
  -- The ghost run, from the ghost's virtual state at the real virtual state's `rip`.
  have hfg0 : FrameInv S s ((S.virt xh).jump (FForm.virtAt (some F) kept x).rip) :=
    hfr.1.congr rfl rfl rfl
  have hcg0 : CacheInv cache ((S.virt xh).jump (FForm.virtAt (some F) kept x).rip) :=
    (Ryo.Proofs.RegCache.inv_jump _ _ _).2 hci
  have hbi : BInv S s (xh.jump (addrAt S.ctx (posOf S.r s.pc))) :=
    vt_bInv_used hfr (by rw [hs, ← hcu]; exact hci)
  obtain ⟨op, ops, s', y', hi', hfull, hops, hstep, hy', hrr, hcc, -, hbr, hf', hrbp', hrsp'⟩ :=
    inline_ghost_run hD H (inlineBelowLink_of H.frameBounds) (inlineEscBounded_of H)
      H.inlineClsOk hP hcro hh hdi hemit hs hfg0 hcg0 ⟨_, hbi⟩ hsafe
  have hseqR : sequence cls ops = some (cand, (none : Option Cond)) := by
    rw [← inline_seq_map (posOf S.r), hops]; exact hseq
  obtain ⟨-, hext, -⟩ := inline_class_of hmem
  have hemv := CacheStep.emit_virt S.ctx F hci.1 hext (H.inlineClsOk _ _ hmem).2 hseqR
  rw [hemit] at hemv
  have hcsO : ∀ it ∈ out, cacheSafe it = true := dinline_cacheSafe hci hmem hseqR hemit
  obtain ⟨hkq, hdq, hrf, hdisj⟩ := dinline_items_free hD H DH hP hr hdi hemit hsk
  subst hkq
  have hcs : ∀ it ∈ q.items, cacheSafe it = true := fun it hit => hcsO it (hsub it hit)
  have hrb : ∀ it ∈ q.items, readBytes it ≤ 2 ^ 32 := fun it hit =>
    readBytes_le_of_cacheSafe (hcs it hit)
  -- The real virtual state against the ghost's.
  have ha0 : XAgreeAt ((S.virt xh).reg .rbp) P (FForm.virtAt (some F) q.items x)
      ((S.virt xh).jump (FForm.virtAt (some F) q.items x).rip) := by
    obtain ⟨h1, h2, h3, -, h5⟩ := xAgree_virt ha
    rw [hvx x] at h1 h2 h3 h5
    exact ⟨h1, h2, h3, rfl, h5⟩
  obtain ⟨-, -, -, -, -, -, hpkI⟩ := dinline_insn H hP hr
  have hkept : S.c.d.items[s.pc]? = some q.items := by
    rw [hs]
    simp [sim_reducedOf_items hD.reduced, hk, hpkI]
  have hlr := kept_loadRip_apart H DH hfg0 (ghostOk_inFrame hg) hkept
  have hin' : InlineAt S s.pc := ⟨op, ops, hi', by simp [hfull, classOf_of_mem hmem]⟩
  have hKA : KeptApart S.ctx (((S.virt xh).jump (FForm.virtAt (some F) q.items x).rip).reg .rbp)
      P q.items (FForm.virtAt (some F) q.items x) := by
    cases oc with
    | none => exact keptApart_none _ _ hg _ _
    | some C =>
      obtain ⟨hpat, hesc⟩ := hg
      obtain ⟨s1, hsc, hv⟩ := Step.step_native hi' hfull (H.inlineOk _ _ hmem).opShape hstep
      obtain ⟨vals, -, ctl, st', -, hn, -, hos, -, -⟩ :=
        Step.stepView_native hfull (H.inlineOk _ _ hmem).opShape
          (H.inlineOk _ _ hmem).notResume (H.inlineOk _ _ hmem).notUnreachable hv
      obtain ⟨st0, x0, hg0⟩ := H.globals
      have hglob : Ryo.Proofs.Inline.Globals S.ctx S.c.ρ s1.st
          ((S.virt xh).jump (FForm.virtAt (some F) q.items x).rip) :=
        afterScopes_globals hg0 hfg0.rrel hfg0.mem (H.frameBounds.scope_size s.pc) s1 hsc
      have hrunR : ∀ op' ops' f', S.c.d.insns[s.pc]? = some (.native op' ops') →
          op'.full = some f' → ∃ vals ch ctl st',
            Ryo.Proofs.Inline.nativeVals S.c.ρ f' ops' = some vals ∧
            OpSem.opSem f' vals s1.st ch = .ok (ctl, st') := by
        intro op' ops' f' hi2 hf2
        rw [hi'] at hi2
        cases hi2
        rw [hfull] at hf2
        cases hf2
        exact ⟨vals, {}, ctl, st', hn, hos⟩
      exact dinline_keptApart hD H C
        (fun d dr => DH.emptyNotTarget s.pc (by rw [hs]; exact hk) d dr) (DH.forms s.pc) hfg0
        (by rw [hs, ← hcu]; exact hcg0) hpat (hesc hkn) (hkr C rfl hkn) hkn (by rw [hs]; exact hk)
        hin' hkept ha0 hlr hsc hglob hrunR hcs hrb
  obtain ⟨ds, xv', hds, hxv, hag⟩ := execItems_skip_free S.ctx hsk hcs (dinline_pure DH k) hrf
    hdisj hlr rfl ha0 hKA hy'
  -- The real machine fetches the kept items in their `spFrame` form.
  have hsd : ∀ i ∈ q.items, i.SpDispOk F := fun i hi => by
    obtain ⟨p', n, hdi'⟩ := hdk i hi
    exact spDisp_of_decodeItem (H.spDispOk F hspF) rfl hspF hdi'
  have hz : (FForm.virtAt (some F) q.items x).reg .rbp =
      ((S.virt xh).jump (FForm.virtAt (some F) q.items x).rip).reg .rbp := by
    show (FForm.virt (some F) x).reg .rbp = (S.virt xh).reg .rbp
    rw [hvx xh]
    show (x.setReg .rbp (x.rsp + F.setWidth 64)).reg .rbp =
      (xh.setReg .rbp (xh.rsp + F.setWidth 64)).reg .rbp
    rw [X86.State.reg_setReg, X86.State.reg_setReg, hrsp]
  have hrun := dinline_fetchRun H hfg0 hcg0 hi' hfull hmem hseqR hstep hns
    (fun it hit => by rw [hemit]; exact hsub it hit) _ hz
  obtain ⟨hsteps, hxvr, -⟩ := steps_of_run_fb (fb := some F) (items := q.items) (pos := p)
    (x := x) (xv' := xv')
    (fun i hi => (hemv i (hsub i hi)).1)
    (fun F' hF' => by
      obtain rfl := Option.some.inj hF'
      exact hsd)
    (fun i hi => (hemv i (hsub i hi)).2.1) (fun i hi => (hemv i (hsub i hi)).2.2.1)
    (CacheStep.canon_map_of (fun i hi => (hemv i (hsub i hi)).2.2.2) p)
    hcode (ha.2.2.2.1.trans hrip) hin hrun hxv
  -- The ghost after, made real with the entry's `rbp`.
  have e1 : y'.rsp + F.setWidth 64 = y'.reg .rbp := by
    rw [hrbp', hrsp']
    show (S.virt xh).rsp + F.setWidth 64 = (S.virt xh).reg .rbp
    rw [hvx xh]
    show (xh.setReg .rbp (xh.rsp + F.setWidth 64)).rsp + F.setWidth 64 =
      (xh.setReg .rbp (xh.rsp + F.setWidth 64)).reg .rbp
    rw [FForm.rsp_setReg_rbp, X86.State.reg_setReg]
  have hvh : S.virt ((y'.jump xv'.rip).setReg .rbp (xh.reg .rbp)) = y'.jump xv'.rip := by
    rw [hvx]
    show ((y'.jump xv'.rip).setReg .rbp (xh.reg .rbp)).setReg .rbp
      (((y'.jump xv'.rip).setReg .rbp (xh.reg .rbp)).rsp + F.setWidth 64) = y'.jump xv'.rip
    rw [FForm.rsp_setReg_rbp, FForm.setReg_setReg,
      show (y'.jump xv'.rip).rsp + F.setWidth 64 = (y'.jump xv'.rip).reg .rbp from e1,
      X86.State.setReg_reg_self]
  have hr1 : xv'.regs = y'.regs := hag.1
  have e2 : xv'.rsp + F.setWidth 64 = xv'.reg .rbp := by
    have h := e1
    simp only [X86.State.rsp, X86.State.reg] at h ⊢
    rw [hr1]
    exact h
  have hvR : S.virt (FForm.real (some F) (x.reg .rbp) xv') = xv' := by
    rw [hvx]
    show (xv'.setReg .rbp (x.reg .rbp)).setReg .rbp
      ((xv'.setReg .rbp (x.reg .rbp)).rsp + F.setWidth 64) = xv'
    rw [FForm.rsp_setReg_rbp, FForm.setReg_setReg, e2, X86.State.setReg_reg_self]
  have hregs : (FForm.real (some F) (x.reg .rbp) xv').regs =
      ((y'.jump xv'.rip).setReg .rbp (xh.reg .rbp)).regs := by
    show (xv'.setReg .rbp (x.reg .rbp)).regs = ((y'.jump xv'.rip).setReg .rbp (xh.reg .rbp)).regs
    rw [hrbpx]
    show (fun i => if i = X86.Reg.rbp.idx then xh.reg .rbp else xv'.regs i) =
      (fun i => if i = X86.Reg.rbp.idx then xh.reg .rbp else (y'.jump xv'.rip).regs i)
    exact congrArg (fun r : Fin 16 → BitVec 64 => fun i =>
      if i = X86.Reg.rbp.idx then xh.reg .rbp else r i) hr1
  have hpc : s'.pc = k + 1 := by
    have h : s'.pc = s.pc + 1 := hbr
    rw [h, hs]
  have hnext : s'.pc = k + 1 → S.c.inRegion (k + 1) = false := fun h => by
    obtain ⟨p1', ctr', hpq'⟩ := hP.proto
    have h1 := hD.nextBody hs hP.body (.step hstep) hP.lt
      (by rw [(Array.getElem?_eq_some_iff.1 hpq').2]; exact (inline_read_sites hr : q.sites = []))
    rwa [h] at h1
  have hstop : S.c.inRegion (k + 1) = false → S.start (k + 1) = c'.pos := fun h =>
    inline_nop_none (inline_read_bare hr) (hP.nop h)
  refine Reach.steps hsteps (.done ⟨s', (y'.jump xv'.rip).setReg .rbp (xh.reg .rbp), ds, hstep,
    ⟨⟨by rw [hvh]; exact hf'.congr rfl rfl rfl,
      fun h => (X86.State.reg_setReg _ .rbp (xh.reg .rbp)).trans (hfr.2 h)⟩, .inl ⟨?_, ?_⟩⟩,
    hds, hdq ds hds, ?_⟩)
  · show xv'.rip = _
    rw [hxvr, hpc, hstop (hnext hpc), hq]
  · rw [hvh, hpc, hP.cache (hnext hpc)]
    exact (Ryo.Proofs.RegCache.inv_jump cache' y' xv'.rip).2 hcc
  · refine xAgree_of_virt hregs ?_
    rw [hvR, hvh]
    have hv : vfp S ((y'.jump xv'.rip).setReg .rbp (xh.reg .rbp)) =
        ((S.virt xh).jump (FForm.virtAt (some F) q.items x).rip).reg .rbp := by
      unfold vfp
      rw [hvh]
      exact hrbp'
    rw [hv]
    exact hag

/-- T6 piece 3 (**machine level**): an inline sequence read at `p` with the cache `cache`, from
the real `x` agreeing with the ghost `xh` but at `P`: R steps to `s'`, the real machine fetches
and runs `kept` (`link_inline_drop`; `execItems_skip`, its reads apart from `P` by
`keptApart_of_live` with `krInv_hrd`, `KrOk`), the ghost runs `out` (`inline_ghost_run` on
`S.virt xh`) and is re-jumped to the real `rip`; the two agree but at `PNext P ds q.items`, `ds`
the dropped stores the sequence consumed (none unless `q.dropped`). -/
theorem dinline_machine (hD : Decodes S code relocs rodata callSites dropped scopes mode)
    (H : Hyps S) {oc : Option (Cert S)} (DH : DHyps S oc) {k p : Nat} {cache : Cache}
    (hcro : CacheRegsOk S cache) (hcu : cache = S.used k) {q : Proto} {c' : Cursor} {cache' : Cache}
    {dr' : List DroppedStore} (hP : ProtoFacts S k p q c' cache')
    (hr : (inlineInsn cache (S.dr k) true).run (atPos S.body p) =
      .ok (some (q, cache', dr'), c')) :
    ∀ s x P xh, s.pc = k → GhostOk S oc s P → KrOk S oc s P → FrameInvR S s xh →
      XAgree S P x xh → xh.rip = addrAt S.ctx p → CacheInv cache (S.virt xh) →
      RSafe S.Safe S.c s →
      Reach S.ctx S.E (fun x' => ∃ s' xh' ds, R.step S.c s {} = .ok (.step s') ∧
        BInv S s' xh' ∧ S.dr k = ds ++ dr' ∧ (ds ≠ [] → q.dropped = true) ∧
        XAgree S (PNext P ds q.items) x' xh') x := by
  cases hfp : S.c.mode.framePointer
  · exact dinline_machine_nofp hD H DH hcro hcu hP hr hfp
  · exact dinline_machine_fp hD H DH hcro hcu hP hr hfp

/-- A byte dropped store `k` writes (but its flag byte) is dead into each successor
(`droppedOk`, bit by bit). -/
theorem droppedOk_bit {d : Decoded} {fl : Frame.Flow} {live : Array Nat} {k : Nat}
    (h : Frame.droppedOk d fl live k = true) {i : Nat}
    (hd : (Frame.droppedBitsAt d k).testBit i = true)
    (hfl : (Frame.flagBits d k).testBit i = false) {t : Nat} (ht : t ∈ fl.succ[k]!) :
    (live[t]!).testBit i = false := by
  unfold Frame.droppedOk at h
  unfold Frame.droppedBitsAt at hd
  cases hs : Frame.droppedStore d k with
  | none => simp [hs] at h
  | some pw =>
    obtain ⟨sl, w⟩ := pw
    rw [hs] at h hd
    simp only [beq_iff_eq] at h
    cases hp : (live[t]!).testBit i
    · rfl
    · exfalso
      have hl : (fl.liveOut live k).testBit i = true := by
        rw [testBit_liveOut]; exact List.any_eq_true.2 ⟨t, ht, hp⟩
      refine testBit_and_zero h ?_ hd
      rw [testBit_diff, hl, hfl]; rfl

/-- The fall-through of a native instruction of an `op`, `br`, `switch` or `lpad` shape, in range,
is one of `flow`'s successors (`flow_succ_next` for these shapes). -/
theorem flow_succ_fall {d : Decoded} {k : Nat} {op : Reduced.Opcode} {ops : List (Opnd Nat)}
    (hi : d.insns[k]? = some (.native op ops))
    (hs : op.info.shape = .op ∨ op.info.shape = .br ∨ op.info.shape = .switch ∨
      op.info.shape = .lpad)
    (hn : k + 1 < d.insns.size) : k + 1 ∈ (Frame.flow d).1[k]! := by
  have hk : k < d.insns.size := by omega
  unfold Frame.flow
  simp only [Id.run_bind, Id.run_pure, Std.Legacy.Range.forIn'_eq_forIn'_range',
    Std.Legacy.Range.size]
  refine forIn'_push_mem (R := fun a x => ∀ op ops, d.insns[a]? = some (.native op ops) →
    (op.info.shape = .op ∨ op.info.shape = .br ∨ op.info.shape = .switch ∨
      op.info.shape = .lpad) → a + 1 < d.insns.size → a + 1 ∈ x) _ ?_ (by simpa using hk)
    (fun x hR => hR op ops hi hs hn)
  intro a h b
  refine ⟨_, rfl, ?_⟩
  intro op' ops' hop hs' hn'
  have hd : ∀ hh : a < d.insns.size, d.insns[a]'hh = .native op' ops' := fun hh => by
    rw [Array.getElem?_eq_getElem hh] at hop
    exact Option.some.inj hop
  simp only [hd]
  rcases hs' with h | h | h | h <;> simp [h, hn']

/-- The successor of inline instruction `k`'s R step is one of the flow's, or past the code
(where every liveness is empty). -/
theorem dinline_succ (hD : Decodes S code relocs rodata callSites dropped scopes mode)
    (H : Hyps S) (C : Cert S) {k p : Nat} {cache : Cache} {q : Proto} {c' : Cursor}
    {cache' : Cache} {dr' : List DroppedStore} (hP : ProtoFacts S k p q c' cache')
    (hr : (inlineInsn cache (S.dr k) true).run (atPos S.body p) =
      .ok (some (q, cache', dr'), c'))
    {s s' : R.RState} (hs : s.pc = k) (hstep : R.step S.c s {} = .ok (.step s')) :
    k < C.fl.succ.size ∧ (s'.pc ∈ C.fl.succ[k]! ∨ C.fl.succ.size ≤ s'.pc) := by
  have hk := hP.lt
  obtain ⟨-, hh, cand, br, out, hdi, -⟩ := inlineInsn_read_drop hr
  obtain ⟨cls, hmem, -⟩ := decodeInline_spec hdi
  obtain ⟨i, hi, hio⟩ := hP.insn
  obtain ⟨p1, counter, hpk⟩ := hP.proto
  have hpk' : S.r.protos[k] = { q with pos := p1, counter } := by
    rw [Array.getElem?_eq_getElem hk] at hpk; exact Option.some.inj hpk
  have hio' := hio hk
  rw [hpk'] at hio'
  unfold InsnOf at hio'
  simp only [hh] at hio'
  obtain ⟨op, ops, hof, rfl, -⟩ := hio'
  have hfull := inline_full_of hof
  have hok := H.inlineOk _ _ hmem
  have hi' : S.c.d.insns[s.pc]? = some (.native op ops) := hs ▸ hi
  obtain ⟨s1, hsc, hv⟩ := Step.step_native hi' hfull hok.opShape hstep
  obtain ⟨vals, t, ctl, st', pc', -, hctl, -, hsucc, ho⟩ :=
    Step.stepView_native hfull hok.opShape hok.notResume hok.notUnreachable hv
  have hpc : s'.pc = pc' := by cases ho; rfl
  have hk1 : s1.pc = k := by rw [(Ryo.Proofs.Scope.scopes_keeps _ hsc).pc, hs]
  rw [hk1] at hsucc
  have hsz : C.fl.succ.size = S.c.d.insns.size := by rw [flowOf_succ C.hfl, flow_succ_size]
  have hkn : k < S.c.d.insns.size := (reducedOf_insns hD.reduced).1 ▸ hk
  refine ⟨hsz ▸ hkn, ?_⟩
  rw [hpc]
  rcases Nat.lt_or_ge pc' S.c.d.insns.size with hlt | hge
  · left
    rw [flowOf_succ C.hfl]
    rcases inline_succ hsucc with rfl | hx
    · have hshape := reduced_shape hfull
      rcases Step.opShape_cases hok.opShape with h | h | h | h | h
      · exact flow_succ_fall hi (.inl (hshape.trans h)) hlt
      · exact flow_succ_fall hi (.inr (.inl (hshape.trans h))) hlt
      · exact flow_succ_fall hi (.inr (.inr (.inl (hshape.trans h)))) hlt
      · -- A `trap` has no successor.
        exfalso
        have ht : t = .trap := by
          first
            | (unfold R.nativeCtl at hctl; simp [h] at hctl; exact hctl.symm)
            | (unfold R.nativeCtl at hctl; simp [h, pure] at hctl; exact hctl.symm)
            | (unfold R.nativeCtl at hctl; simp only [h] at hctl; exact (Option.some.inj hctl).symm)
        subst ht
        cases ctl <;> simp [R.Then.succ] at hsucc
      · exact flow_succ_fall hi (.inr (.inr (.inr (hshape.trans h)))) hlt
    · obtain ⟨o, hoo, hxo⟩ := inline_ctl_targets hctl hx
      exact flow_succ_targetsOf hi hoo hxo hlt
  · right
    rw [hsz]
    exact hge

/-- Inline instruction `k`'s effects are its items' (`inlineEffects q.items`), and its flow row's
`kill` and `uninit` are those of `rowOf` on them. -/
theorem dinline_row (hD : Decodes S code relocs rodata callSites dropped scopes mode)
    (H : Hyps S) (C : Cert S) {k p : Nat} {cache : Cache} {q : Proto} {c' : Cursor}
    {cache' : Cache} {dr' : List DroppedStore} (hP : ProtoFacts S k p q c' cache')
    (hr : (inlineInsn cache (S.dr k) true).run (atPos S.body p) =
      .ok (some (q, cache', dr'), c')) :
    ∃ op ops cls eb, S.c.d.insns[k]? = some (.native op ops) ∧ op.full = some q.op ∧
      (q.op, cls) ∈ inlineOps ∧
      C.fl.kill[k]! = (Frame.Flow.rowOf S.c.d C.facts (Frame.scopesAt S.c.d) k
        (Frame.inlineEffects q.items) eb).kill ∧
      C.fl.uninit[k]! = (Frame.Flow.rowOf S.c.d C.facts (Frame.scopesAt S.c.d) k
        (Frame.inlineEffects q.items) eb).uninit ∧
      C.fl.ends[k]! = (Frame.Flow.rowOf S.c.d C.facts (Frame.scopesAt S.c.d) k
        (Frame.inlineEffects q.items) eb).ends := by
  have hk := hP.lt
  obtain ⟨op, ops, cls, hi, hfull, hmem, hpk⟩ := dinline_insn H hP hr
  have hkn : k < S.c.d.insns.size := (reducedOf_insns hD.reduced).1 ▸ hk
  obtain ⟨e, he, r, ⟨eb, hrow⟩, hkl, hun, hen⟩ := flowOf_row C.hfl hkn
  have hik : S.c.d.insns[k]! = .native op ops := by
    rw [getElem!_pos S.c.d.insns k hkn]
    rw [Array.getElem?_eq_getElem hkn] at hi
    exact Option.some.inj hi
  have hitems : S.c.d.items[k]? = some q.items := by
    simp [sim_reducedOf_items hD.reduced, hk, hpk]
  rw [hik, hitems, Option.getD_some] at he
  have he' : e = Frame.inlineEffects q.items := by
    simp only [Frame.effects, hfull, Option.bind_some, classOf_of_mem hmem, Option.isSome_some,
      ↓reduceIte, pure, Except.pure, Except.ok.injEq] at he
    first | exact he.symm | exact he
  subst he'
  refine ⟨op, ops, cls, eb, hi, hfull, hmem, ?_, ?_, ?_⟩
  · rw [hkl, ← hrow]
  · rw [hun, ← hrow]
  · rw [hen, ← hrow]

/-- (1) What inline instruction `k` writes for sure (`kill`) its kept items write. -/
theorem dinline_kill (hD : Decodes S code relocs rodata callSites dropped scopes mode)
    (H : Hyps S) (C : Cert S) {k p : Nat} {cache : Cache} {q : Proto} {c' : Cursor}
    {cache' : Cache} {dr' : List DroppedStore} (hP : ProtoFacts S k p q c' cache')
    (hr : (inlineInsn cache (S.dr k) true).run (atPos S.body p) =
      .ok (some (q, cache', dr'), c')) :
    ∀ o, InFrame S o → (C.fl.kill[k]!.bits).testBit (bit S o) = true → KeptW q.items o := by
  obtain ⟨op, ops, cls, eb, -, -, -, hkl, -, -⟩ := dinline_row hD H C hP hr
  intro o hin hb
  obtain ⟨h1, h2⟩ := hin
  rw [hkl] at hb
  simp only [Frame.Flow.rowOf] at hb
  rw [testBit_rangesBits] at hb
  obtain ⟨rg, hrg, hbit⟩ := List.any_eq_true.1 hb
  obtain ⟨off, m, hmw, rfl⟩ := opndRanges_kill hrg
  simp only [Frame.inlineEffects, List.mem_flatMap, List.mem_append, List.mem_map,
    Option.mem_toList] at hmw
  obtain ⟨it, hit, ⟨⟨mm, n⟩, -, heq⟩ | ⟨⟨mm, n⟩, hfw, heq⟩⟩ := hmw
  · simp at heq
  · simp only [Prod.mk.injEq, Frame.Access.write.injEq] at heq
    obtain ⟨rfl, rfl⟩ := heq
    simp only [Bool.and_eq_true] at hbit
    obtain ⟨hb1, hb2⟩ := hbit
    have hb1' := by first | exact of_decide_eq_true hb1 | exact hb1
    have hb2' := by first | exact of_decide_eq_true hb2 | exact hb2
    simp only [Frame.range, bit] at hb1' hb2'
    exact ⟨it, hit, mm, n, hfw, by omega, by omega⟩

/-- (7) An inline row makes nothing `Uninit` (it isn't a call). -/
theorem dinline_uninit (hD : Decodes S code relocs rodata callSites dropped scopes mode)
    (H : Hyps S) (C : Cert S) {k p : Nat} {cache : Cache} {q : Proto} {c' : Cursor}
    {cache' : Cache} {dr' : List DroppedStore} (hP : ProtoFacts S k p q c' cache')
    (hr : (inlineInsn cache (S.dr k) true).run (atPos S.body p) =
      .ok (some (q, cache', dr'), c')) :
    ∀ i, (C.fl.uninit[k]!.bits).testBit i = false := by
  obtain ⟨op, ops, cls, eb, hi, hfull, hmem, -, hun, -⟩ := dinline_row hD H C hP hr
  have hkn : k < S.c.d.insns.size := (reducedOf_insns hD.reduced).1 ▸ hP.lt
  have hik : S.c.d.insns[k]! = .native op ops := by
    rw [getElem!_pos S.c.d.insns k hkn]
    rw [Array.getElem?_eq_getElem hkn] at hi
    exact Option.some.inj hi
  have hshape := reduced_shape hfull
  have hok := H.inlineOk _ _ hmem
  have hu : C.fl.uninit[k]! = [] := by
    rw [hun]
    rcases Step.opShape_cases hok.opShape with h | h | h | h | h <;>
      simp [Frame.Flow.rowOf, Frame.Flow.callInfo, hik, hshape.trans h]
  intro i
  rw [hu]
  simp [Frame.Ranges.bits]

/-- **Open** (DS-T9, dropped form vs `droppedStore`): (2) the dropped stores the sequence at `k`
consumed write bytes of `droppedBitsAt k` (`DroppedForm`'s `[rbp + off]` is `Frame.droppedStore`'s
`"d"` slot, at its width), in the frame, so `k` is a dropped instruction; and they are private
after the step (`droppedPrivate`, `EscSound`). -/
theorem dinline_dropW (hD : Decodes S code relocs rodata callSites dropped scopes mode)
    (H : Hyps S) (C : Cert S) {k p : Nat} {cache : Cache} {q : Proto} {c' : Cursor}
    {cache' : Cache} {dr' : List DroppedStore} (hP : ProtoFacts S k p q c' cache')
    (hr : (inlineInsn cache (S.dr k) true).run (atPos S.body p) =
      .ok (some (q, cache', dr'), c'))
    {s s' : R.RState} (hs : s.pc = k) (hstep : R.step S.c s {} = .ok (.step s'))
    (hesc : EscSound S C s) {ds : List DroppedStore} (hds : S.dr k = ds ++ dr') :
    ∀ o, DropW ds o → k ∈ S.c.d.dropped.toList ∧ InFrame S o ∧
      (Frame.droppedBitsAt S.c.d k).testBit (bit S o) = true ∧ s'.st.escapedAt o = none := by
  obtain ⟨op, ops, cls, hi, hfull, hmem, -⟩ := dinline_insn H hP hr
  have hok := H.inlineOk _ _ hmem
  have hi' : S.c.d.insns[s.pc]? = some (.native op ops) := hs ▸ hi
  obtain ⟨s1, hsc, hv⟩ := Step.step_native hi' hfull hok.opShape hstep
  obtain ⟨vals, t, ctl, st', pc', hvals, -, hop, -, ho⟩ :=
    Step.stepView_native hfull hok.opShape hok.notResume hok.notUnreachable hv
  cases ho
  exact dropForm_dropW hD C hP hr hs hsc (Ryo.Proofs.OpFacts.opSem_out hop).2.1 hesc hds

/-- **Open** (DS-T9, dropped form vs `droppedStore`): (3) an overflow op's flag byte
(`flagSlot`'s) is written by its kept flag store. -/
theorem dinline_flag (hD : Decodes S code relocs rodata callSites dropped scopes mode)
    (H : Hyps S) (C : Cert S) {k p : Nat} {cache : Cache} {q : Proto} {c' : Cursor}
    {cache' : Cache} {dr' : List DroppedStore} (hP : ProtoFacts S k p q c' cache')
    (hr : (inlineInsn cache (S.dr k) true).run (atPos S.body p) =
      .ok (some (q, cache', dr'), c')) :
    ∀ o, InFrame S o → (Frame.flagBits S.c.d k).testBit (bit S o) = true → KeptW q.items o := by
  exact dropForm_flag hD H C hP hr

/-- Inline instruction `k`'s R step: its scopes, then `opSem` of its opcode, then the control. -/
theorem dinline_step (H : Hyps S) {k p : Nat} {cache : Cache} {q : Proto} {c' : Cursor}
    {cache' : Cache} {dr' : List DroppedStore} (hP : ProtoFacts S k p q c' cache')
    (hr : (inlineInsn cache (S.dr k) true).run (atPos S.body p) =
      .ok (some (q, cache', dr'), c'))
    {s s' : R.RState} (hs : s.pc = k) (hstep : R.step S.c s {} = .ok (.step s')) :
    ∃ op ops s1 vals ctl st' pc', S.c.d.insns[s.pc]? = some (.native op ops) ∧
      op.full = some q.op ∧ (S.c.scopesAt s.pc).foldlM R.applyScope s = .ok s1 ∧
      Ryo.Proofs.Inline.nativeVals S.c.ρ q.op ops = some vals ∧
      OpSem.opSem q.op vals s1.st {} = .ok (ctl, st') ∧
      s' = { s1 with pc := pc', st := st' } := by
  obtain ⟨op, ops, cls, hi, hfull, hmem, -⟩ := dinline_insn H hP hr
  have hok := H.inlineOk _ _ hmem
  have hi' : S.c.d.insns[s.pc]? = some (.native op ops) := hs ▸ hi
  obtain ⟨s1, hsc, hv⟩ := Step.step_native hi' hfull hok.opShape hstep
  obtain ⟨vals, t, ctl, st', pc', hvals, -, hop, -, ho⟩ :=
    Step.stepView_native hfull hok.opShape hok.notResume hok.notUnreachable hv
  refine ⟨op, ops, s1, vals, ctl, st', pc', hi', hfull, hsc, hvals, hop, ?_⟩
  cases ho
  rfl

/-- A byte private before the scopes, which no `Escape` among them covers, stays private. -/
theorem escNone_fold {o : Int} : ∀ (l : List R.Scope) {u u1 : R.RState},
    l.foldlM R.applyScope u = .ok u1 → u.st.escapedAt o = none →
    (∀ sc ∈ l, ∀ a, sc.kind = .escape a →
      ¬ (sc.frameOffset.toInt ≤ o ∧ o < sc.frameOffset.toInt + sc.size)) →
    u1.st.escapedAt o = none
  | [], u, u1, h, hn, _ => by cases h; exact hn
  | sc :: l, u, u1, h, hn, hesc => by
    simp only [List.foldlM_cons, bind, Except.bind] at h
    cases h1 : R.applyScope u sc with
    | error e => simp [h1] at h
    | ok u2 =>
      simp only [h1] at h
      refine escNone_fold l h ?_ (fun sc' hs => hesc sc' (List.mem_cons_of_mem _ hs))
      unfold R.applyScope at h1
      split at h1
      · rename_i a hk
        exact (escape_private h1 hn (hesc sc (List.mem_cons_self ..) a hk)).1
      · exact (storageEnd_private h1 hn).1
      · cases h1
        exact hn

/-- **Open** (DS-T9, dropped form vs `droppedStore`): the R operation of inline instruction `k`
writes only frame bytes its kept items or the dropped stores consumed write (its `"d"` slot,
`Frame.droppedStore`, and an overflow op's flag slot, `flagSlot`, against `DroppedForm` and the
emitted stores). -/
theorem dinline_opSem_frame (hD : Decodes S code relocs rodata callSites dropped scopes mode)
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
  exact dropForm_opSem_frame hD H hP hr hi hv hop hds

/-- The R step of inline instruction `k` (T6 piece 4's links (4)–(6)): (4) an `Escape` before `k` escapes only
`escRead`'s bytes; (5) a private frame byte neither the kept items nor the dropped stores write
is `Uninit` after the step if an `End` before `k` covers it, and stays `Uninit`; (6) escape
soundness carries over (`escPre_next`). -/
theorem dinline_rstep (hD : Decodes S code relocs rodata callSites dropped scopes mode)
    (H : Hyps S) (C : Cert S) {k p : Nat} {cache : Cache} {q : Proto} {c' : Cursor}
    {cache' : Cache} {dr' : List DroppedStore} (hP : ProtoFacts S k p q c' cache')
    (hr : (inlineInsn cache (S.dr k) true).run (atPos S.body p) =
      .ok (some (q, cache', dr'), c'))
    {s s' : R.RState} (hs : s.pc = k) (hstep : R.step S.c s {} = .ok (.step s'))
    (hesc : EscSound S C s) {ds : List DroppedStore} (hds : S.dr k = ds ++ dr') :
    (∀ o, InFrame S o → s.st.escapedAt o = none →
      (C.fl.escRead[k]!).testBit (bit S o) = false → s'.st.escapedAt o = none) ∧
    (∀ o, InFrame S o → s.st.escapedAt o = none →
      (C.fl.escRead[k]!).testBit (bit S o) = false → ¬ KeptW q.items o → ¬ DropW ds o →
      ((C.fl.ends[k]!.bits).testBit (bit S o) = true → s'.st.byteAt o = .ok .uninit) ∧
      (s.st.byteAt o = .ok .uninit → s'.st.byteAt o = .ok .uninit)) ∧
    (s'.pc < S.c.d.insns.size → EscSound S C s') := by
  obtain ⟨op, ops, s1, vals, ctl, st', pc', hi, hfull, hsc, hvals, hop, rfl⟩ :=
    dinline_step H hP hr hs hstep
  have hescK : st'.escaped = s1.st.escaped := (Ryo.Proofs.OpFacts.opSem_out hop).2.1
  have hkn : k < S.c.d.insns.size := (reducedOf_insns hD.reduced).1 ▸ hP.lt
  -- An `Escape` before `k` covers only `escRead`'s bytes.
  have hnoesc : ∀ o, InFrame S o → (C.fl.escRead[k]!).testBit (bit S o) = false →
      ∀ sc ∈ S.c.scopesAt s.pc, ∀ a, sc.kind = .escape a →
        ¬ (sc.frameOffset.toInt ≤ o ∧ o < sc.frameOffset.toInt + sc.size) := by
    intro o hin hb sc hsc' a hkind hr'
    obtain ⟨hf1, hf2⟩ := hin
    obtain ⟨h1, h2⟩ := hr'
    rw [hs] at hsc'
    unfold R.Code.scopesAt at hsc'
    obtain ⟨x, hx, rfl⟩ := List.mem_map.1 hsc'
    obtain ⟨hxm, hxk⟩ := List.mem_filter.1 hx
    obtain ⟨j, hj⟩ := List.mem_iff_getElem?.1 hxm
    rw [Array.getElem?_toList] at hj
    have hxk' : x.1 = k := by simpa using hxk
    have hj' : S.c.d.scopes[j]? = some (k, x.2) := by rw [hj, ← hxk']
    have hmem := frame_scopesAt_mem hj' hkn
    have := flowOf_escRead_escape C.hfl hkn hmem hkind (i := bit S o)
      (by simp only [Frame.range, bit]; omega) (by simp only [Frame.range, bit]; omega)
    rw [hb] at this
    cases this
  have hpriv1 : ∀ o, InFrame S o → s.st.escapedAt o = none →
      (C.fl.escRead[k]!).testBit (bit S o) = false → s1.st.escapedAt o = none :=
    fun o hin hn hb => escNone_fold _ hsc hn (hnoesc o hin hb)
  have hpriv' : ∀ o, InFrame S o → s.st.escapedAt o = none →
      (C.fl.escRead[k]!).testBit (bit S o) = false → st'.escapedAt o = none := by
    intro o hin hn hb
    unfold OpSem.State.escapedAt
    rw [hescK]
    exact hpriv1 o hin hn hb
  refine ⟨hpriv', ?_, ?_⟩
  · intro o hin hn hb hnk hnd
    have hn' := hpriv' o hin hn hb
    have hfr := dinline_opSem_frame hD H hP hr (hs ▸ hi) hvals hop hds o hin hnk hnd
    refine ⟨fun he => ?_, fun hu => ?_⟩
    · obtain ⟨_, _, _, _, _, _, _, _, _, hen⟩ := dinline_row hD H C hP hr
      rw [hen] at he
      simp only [Frame.Flow.rowOf] at he
      obtain ⟨sc, hsc', hk', h1, h2⟩ := end_scope_of_bit hin he
      show st'.byteAt o = .ok .uninit
      simp only [OpSem.State.byteAt, hn']
      rw [hfr, private_fold _ hsc hn (hnoesc o hin hb)
        (.inr ⟨sc, hs ▸ hsc', hk', h1, h2⟩)]
      all_goals rfl
    · have hu' : s.st.frame o = .uninit := by
        simp only [OpSem.State.byteAt, hn] at hu
        exact Except.ok.inj hu
      show st'.byteAt o = .ok .uninit
      simp only [OpSem.State.byteAt, hn']
      rw [hfr, private_fold _ hsc hn (hnoesc o hin hb) (.inl hu')]
      all_goals rfl
  · intro hlt
    obtain ⟨hk, hsucc'⟩ := dinline_succ hD H C hP hr hs hstep
    have hsz : C.fl.succ.size = S.c.d.insns.size := by rw [flowOf_succ C.hfl, flow_succ_size]
    have hlt' : pc' < S.c.d.insns.size := hlt
    have hm : pc' ∈ C.fl.succ[k]! := by
      rcases hsucc' with h | h
      · exact h
      · have h' : C.fl.succ.size ≤ pc' := h
        omega
    have hpsz : C.fl.pad.size = C.fl.succ.size := (postFix_spec C.hlive).2.1
    have hedge : pc' ∈ C.fl.edges[s.pc]! := by
      rw [hs, flow_edges_get hk (by rw [hpsz]; exact hk)]
      exact List.mem_append_left _ hm
    exact escPre_next C.hesc (by rw [hs]; exact hkn) hesc hsc hescK hedge

/-- T6 piece 4's links: inline instruction `k`'s flow row and R step against its
items. `kill` is what the kept items write (`inlineEffects` of `d.items[k] = q.items`); the
dropped stores consumed write bytes of `droppedBitsAt` (`DroppedForm`, `Frame.droppedStore`'s
`"d"` slot), in the frame, private after the step (`droppedPrivate`, `EscSound`); the flag byte is
the kept flag store's; an `Escape` before `k` escapes only `escRead`'s bytes; a private frame byte
neither the kept items nor the dropped stores write is `Uninit` after if ended before `k`, and
stays `Uninit`; escape soundness carries over (`escPre_next`); an inline row makes nothing
`Uninit`. -/
theorem inline_links (hD : Decodes S code relocs rodata callSites dropped scopes mode)
    (H : Hyps S) (C : Cert S) {k p : Nat} {cache : Cache} {q : Proto} {c' : Cursor}
    {cache' : Cache} {dr' : List DroppedStore} (hP : ProtoFacts S k p q c' cache')
    (hr : (inlineInsn cache (S.dr k) true).run (atPos S.body p) =
      .ok (some (q, cache', dr'), c'))
    {s s' : R.RState} (hs : s.pc = k) (hstep : R.step S.c s {} = .ok (.step s'))
    (hesc : EscSound S C s) {ds : List DroppedStore} (hds : S.dr k = ds ++ dr') :
    (∀ o, InFrame S o → (C.fl.kill[k]!.bits).testBit (bit S o) = true → KeptW q.items o) ∧
    (∀ o, DropW ds o → k ∈ S.c.d.dropped.toList ∧ InFrame S o ∧
      (Frame.droppedBitsAt S.c.d k).testBit (bit S o) = true ∧ s'.st.escapedAt o = none) ∧
    (∀ o, InFrame S o → (Frame.flagBits S.c.d k).testBit (bit S o) = true → KeptW q.items o) ∧
    (∀ o, InFrame S o → s.st.escapedAt o = none →
      (C.fl.escRead[k]!).testBit (bit S o) = false → s'.st.escapedAt o = none) ∧
    (∀ o, InFrame S o → s.st.escapedAt o = none →
      (C.fl.escRead[k]!).testBit (bit S o) = false → ¬ KeptW q.items o → ¬ DropW ds o →
      ((C.fl.ends[k]!.bits).testBit (bit S o) = true → s'.st.byteAt o = .ok .uninit) ∧
      (s.st.byteAt o = .ok .uninit → s'.st.byteAt o = .ok .uninit)) ∧
    (s'.pc < S.c.d.insns.size → EscSound S C s') ∧
    (∀ i, (C.fl.uninit[k]!.bits).testBit i = false) := by
  obtain ⟨h4, h5, h6⟩ := dinline_rstep hD H C hP hr hs hstep hesc hds
  exact ⟨dinline_kill hD H C hP hr, dinline_dropW hD H C hP hr hs hstep hesc hds,
    dinline_flag hD H C hP hr, h4, h5, h6, dinline_uninit hD H C hP hr⟩

/-- T6 piece 4 (**certificate level**): after inline instruction `k`'s R step, `PNext` less the
ended bytes no cache slot covers (`QDrop`) is a patch set at `s'`, with escape soundness and the
kept-read invariant; `QDrop`'s bytes are what `ghost_drop_uninit` takes. From `live_succ`
(old bytes stay dead, or are ended: `Uninit`), `droppedOk_spec` (the dropped bytes are dead
after), `escPre_next`, `krAt_succ_covers`, `krAt_dropped_off`, and the link of `DropW`/`KeptW`
to `droppedBitsAt`/`fl.kill` at `k` (`d.items[k] = q.items`, `inlineEffects`). -/
theorem dinline_patch (hD : Decodes S code relocs rodata callSites dropped scopes mode)
    (H : Hyps S) {oc : Option (Cert S)} (DH : DHyps S oc) (C : Cert S) {k p : Nat}
    {cache : Cache} {q : Proto} {c' : Cursor} {cache' : Cache} {dr' : List DroppedStore}
    (hP : ProtoFacts S k p q c' cache')
    (hr : (inlineInsn cache (S.dr k) true).run (atPos S.body p) =
      .ok (some (q, cache', dr'), c'))
    {s s' : R.RState} {P : Int → Prop} (hs : s.pc = k) (hpat : PatchOk S C s P)
    (hesc : EscSound S C s) (hkr : KrInv S C s P) (hstep : R.step S.c s {} = .ok (.step s'))
    (hsafe : RSafe S.Safe S.c s) {ds : List DroppedStore} (hds : S.dr k = ds ++ dr') :
    (∀ o, QDrop S s' (PNext P ds q.items) o → InFrame S o ∧ s'.st.byteAt o = .ok .uninit ∧
      s'.st.escapedAt o = none ∧ ¬ CacheCovers S s'.pc o) ∧
    PatchOk S C s' (fun o => PNext P ds q.items o ∧ ¬ QDrop S s' (PNext P ds q.items) o) ∧
    (s'.pc < S.c.d.insns.size → EscSound S C s') ∧
    KrInv S C s' (fun o => PNext P ds q.items o ∧ ¬ QDrop S s' (PNext P ds q.items) o) := by
  obtain ⟨hk, hsucc'⟩ := dinline_succ hD H C hP hr hs hstep
  obtain ⟨hL1, hL2, hL3, hL4, hL5, hesc', hL6⟩ := inline_links hD H C hP hr hs hstep hesc hds
  have hcov := coveredAtSound hD
  -- A bit set in a liveness into the successor puts it among `k`'s flow successors.
  have hinL : ∀ i, (C.fl.liveIn[s'.pc]!).testBit i = true → s'.pc ∈ C.fl.succ[k]! := by
    intro i h
    rcases hsucc' with hm | hge
    · exact hm
    · have hsz := (postFix_spec C.hlive).1
      rw [getElem!_neg C.fl.liveIn s'.pc (by omega)] at h
      simp at h
  have hinK : ∀ i, ((C.fl.keptReadLive S.c.d)[s'.pc]!).testBit i = true →
      s'.pc ∈ C.fl.succ[k]! := by
    intro i h
    rcases hsucc' with hm | hge
    · exact hm
    · have hsz := (postFix_spec C.hkept).1
      rw [getElem!_neg (C.fl.keptReadLive S.c.d) s'.pc (by omega)] at h
      simp at h
  -- An old byte of `P` is out of the kept-read liveness into `k`.
  have hkr2 : ∀ o, P o → InFrame S o →
      ((C.fl.keptReadLive S.c.d)[k]!).testBit (bit S o) = false := fun o hp hi => by
    have := hkr o hp hi
    rw [hs] at this
    exact this
  -- No `Escape` before `k` copies an old byte of `P` (it would be kept-read live).
  have hner : ∀ o, P o → InFrame S o → (C.fl.escRead[k]!).testBit (bit S o) = false :=
    fun o hp hi => by
      cases he : (C.fl.escRead[k]!).testBit (bit S o) with
      | false => rfl
      | true =>
        have h2 := keptRead_esc C.hkept hk he
        rw [hkr2 o hp hi] at h2
        cases h2
  -- Not written by the kept items: not killed, not the flag byte.
  have hnkill : ∀ o, InFrame S o → ¬ KeptW q.items o →
      (C.fl.kill[k]!.bits).testBit (bit S o) = false := fun o hi hnk => by
    cases h : (C.fl.kill[k]!.bits).testBit (bit S o) with
    | false => rfl
    | true => exact absurd (hL1 o hi h) hnk
  have hnflag : ∀ o, InFrame S o → ¬ KeptW q.items o →
      (Frame.flagBits S.c.d k).testBit (bit S o) = false := fun o hi hnk => by
    cases h : (Frame.flagBits S.c.d k).testBit (bit S o) with
    | false => rfl
    | true => exact absurd (hL3 o hi h) hnk
  -- The bytes of `PNext`: in the frame, dropped, private after the step.
  have hin1 : ∀ o, PNext P ds q.items o →
      InFrame S o ∧ Dropped S o ∧ s'.st.escapedAt o = none := by
    intro o ho
    obtain ⟨h1, -⟩ := ho
    rcases h1 with hp | hd
    · obtain ⟨hi, hdr, hen, -⟩ := hpat o hp
      exact ⟨hi, hdr, hL4 o hi hen (hner o hp hi)⟩
    · obtain ⟨hm, hi, hb, hen⟩ := hL2 o hd
      exact ⟨hi, testBit_droppedBits hm hb, hen⟩
  -- A byte of `PNext` live into the successor is `Uninit` there.
  have hlive : ∀ o, PNext P ds q.items o → InFrame S o →
      (C.fl.liveIn[s'.pc]!).testBit (bit S o) = true → s'.st.byteAt o = .ok .uninit := by
    intro o ho hi hl
    obtain ⟨h1, hnk⟩ := ho
    by_cases hd : DropW ds o
    · exfalso
      obtain ⟨hm, -, hb, -⟩ := hL2 o hd
      have := droppedOk_bit (C.hdrop k hm) hb (hnflag o hi hnk) (hinL _ hl)
      rw [hl] at this
      cases this
    · rcases h1 with hp | hd'
      · obtain ⟨-, -, hen, hdead⟩ := hpat o hp
        obtain ⟨hend, hun⟩ := hL5 o hi hen (hner o hp hi) hnk hd
        rcases hdead with ⟨-, hdk⟩ | ⟨hu, -⟩
        · cases he : (C.fl.ends[k]!.bits).testBit (bit S o) with
          | true => exact hend he
          | false =>
            exfalso
            have := live_succ C.hlive hk (hinL _ hl) hl (hnkill o hi hnk) (hL6 _) he
            rw [hs] at hdk
            rw [hdk] at this
            cases this
        · exact hun hu
      · exact absurd hd' hd
  refine ⟨?_, ?_, hesc', ?_⟩
  · intro o hq
    obtain ⟨hp1, hu, hnc⟩ := hq
    obtain ⟨hi, -, hen⟩ := hin1 o hp1
    exact ⟨hi, hu, hen, hnc⟩
  · intro o ho
    obtain ⟨hp1, hnq⟩ := ho
    obtain ⟨hi, hdr, hen⟩ := hin1 o hp1
    refine ⟨hi, hdr, hen, ?_⟩
    cases hl : (C.fl.liveIn[s'.pc]!).testBit (bit S o) with
    | false => exact .inl (And.intro hi hl)
    | true =>
      have hu := hlive o hp1 hi hl
      exact .inr ⟨hu, Classical.byContradiction fun hc => hnq ⟨hp1, hu, hc⟩⟩
  · intro o ho hi
    obtain ⟨hp1, hnq⟩ := ho
    show ((C.fl.keptReadLive S.c.d)[s'.pc]!).testBit (bit S o) = false
    have hp1' := hp1
    obtain ⟨h1, hnk⟩ := hp1'
    by_cases hd : DropW ds o
    · obtain ⟨hm, -, hb, -⟩ := hL2 o hd
      cases hl : ((C.fl.keptReadLive S.c.d)[s'.pc]!).testBit (bit S o) with
      | false => rfl
      | true =>
        have := droppedUnread_spec (C.hunread k hm) hb (hnflag o hi hnk) (hinK _ hl)
        rw [hl] at this
        cases this
    · have hp : P o := by
        rcases h1 with hp | hd'
        · exact hp
        · exact absurd hd' hd
      obtain ⟨-, -, hen, -⟩ := hpat o hp
      obtain ⟨hend, -⟩ := hL5 o hi hen (hner o hp hi) hnk hd
      cases hl : ((C.fl.keptReadLive S.c.d)[s'.pc]!).testBit (bit S o) with
      | false => rfl
      | true =>
        exfalso
        have hendc : (C.fl.ends[k]!.bits).testBit (bit S o) = false ∨
            (Frame.coveredAt S.c.d s'.pc).testBit (bit S o) = true := by
          cases he : (C.fl.ends[k]!.bits).testBit (bit S o) with
          | false => exact .inl rfl
          | true =>
            refine .inr ?_
            by_cases hc : CacheCovers S s'.pc o
            · have hsp : s'.pc ≤ S.c.d.insns.size := by
                have h1 := liveOk_edges C.hlive hk (List.mem_append_left _ (hinK _ hl))
                have h2 : C.fl.succ.size = S.c.d.insns.size := by
                  rw [flowOf_succ C.hfl, flow_succ_size]
                omega
              exact hcov s'.pc o hsp hc hi
            · exact (hnq ⟨hp1, hend he, hc⟩).elim
        have := keptRead_succ C.hkept hk (hinK _ hl) hl (hnkill o hi hnk) hendc
        rw [hkr2 o hp hi] at this
        cases this

/-- T6: an inline sequence read at `p` with the cache `cache`, with or without a dropped store,
on the ghost: the machine run (`dinline_machine`), then, with a certificate, the new patch set
(`dinline_patch`) and the ghost re-chosen at its ended uncovered bytes (`ghost_drop_uninit`);
without one nothing is dropped, so nothing differs. -/
theorem dbodySim_inline_at (hD : Decodes S code relocs rodata callSites dropped scopes mode)
    (H : Hyps S) {oc : Option (Cert S)} (DH : DHyps S oc) {k p : Nat} {cache : Cache}
    (hcro : CacheRegsOk S cache) (hcu : cache = S.used k) {q : Proto} {c' : Cursor} {cache' : Cache}
    {dr' : List DroppedStore} (hP : ProtoFacts S k p q c' cache')
    (hr : (inlineInsn cache (S.dr k) true).run (atPos S.body p) =
      .ok (some (q, cache', dr'), c')) :
    DBodySim S oc k p cache := by
  intro s x P xh hs hg hkr hfr ha hrip hci hsafe
  refine (dinline_machine hD H DH hcro hcu hP hr s x P xh hs hg hkr hfr ha hrip hci hsafe).mono ?_
  rintro x' ⟨s', xh', ds, hstep, hbi, hds, hdq, ha'⟩
  refine .inl ⟨s', .step hstep, ?_⟩
  unfold DInv
  cases oc with
  | none =>
    have hP0 : ∀ o, ¬ P o := hg
    refine ⟨PNext P ds q.items, xh', ?_, hbi, ha', fun C hC => by cases hC⟩
    intro o ho
    obtain ⟨h1, -⟩ := ho
    rcases h1 with h | ⟨d, hd, -⟩
    · exact hP0 o h
    · have hq := hdq (List.ne_nil_of_mem hd)
      obtain ⟨p1, counter, hpk⟩ := hP.proto
      have hk := hP.lt
      have hpd : S.r.protos[k].dropped = true := by
        rw [Array.getElem?_eq_getElem hk] at hpk
        rw [Option.some.inj hpk]
        exact hq
      have hm := mem_dropped_of_proto hD hk hpd
      have he := DH.none_empty rfl
      have hsz : 0 < S.c.d.dropped.size := by
        rw [← Array.length_toList]; exact List.length_pos_of_mem hm
      first
        | (simp only [Array.isEmpty, decide_eq_true_eq] at he; omega)
        | (simp [Array.isEmpty] at he; omega)
        | simp_all
  | some C =>
    obtain ⟨hpat, hesc⟩ := hg
    have hkn : s.pc < S.c.d.insns.size := by
      rw [hs]; exact (reducedOf_insns hD.reduced).1 ▸ hP.lt
    have hkr0 : KrInv S C s P := hkr C rfl hkn
    obtain ⟨hq, hpat', hesc', hkr'⟩ :=
      dinline_patch hD H DH C hP hr hs hpat (hesc hkn) hkr0 hstep hsafe hds
    obtain ⟨xh'', hbi'', ha''⟩ := ghost_drop_uninit H hbi ha' hq
    exact ⟨_, xh'', (And.intro hpat' hesc' :
        PatchOk S C s' _ ∧ (s'.pc < S.c.d.insns.size → EscSound S C s')), hbi'', ha'',
      fun C' hC' _ => by cases hC'; exact hkr'⟩

/-- T6: an inline body on the ghost, with or without a dropped store. -/
theorem dbodySim_inline (hD : Decodes S code relocs rodata callSites dropped scopes mode)
    (H : Hyps S) {oc : Option (Cert S)} (DH : DHyps S oc) {k p : Nat} {a : Bool} {q : Proto}
    {cur cur' c' : Cursor} {cache' : Cache} {dr' : List DroppedStore}
    (hP : ProtoFacts S k p q c' cache') (hn : NoArg S.fr S.body p a cur)
    (hc : (callInsn S.fr (S.dr k)).run cur = .ok (none, cur'))
    (hr : (inlineInsn (S.used k) (S.dr k) true).run cur' = .ok (some (q, cache', dr'), c')) :
    DBodySim S oc k p (S.used k) := by
  have e := callInsn_none hc
  have hcur : cur = atPos S.body p := hn
  rw [e, hcur] at hr
  have hk : k ≤ S.r.protos.toList.length := by
    rw [Array.length_toList]; exact Nat.le_of_lt hP.lt
  exact dbodySim_inline_at hD H DH (CacheRegs.cacheRegsOk_of_decodes hD k hk) rfl hP hr

/-- T6: instruction `k` of a main iteration on the ghost (`insnSim_main`'s hypotheses): the
padding and counter check run on `x`, the ghost alongside (the trip's return keeps the frame
window, `TripContract`), then the body (`dbodySim_*`). -/
theorem dinsn_main (hD : Decodes S code relocs rodata callSites dropped scopes mode)
    (H : Hyps S) {oc : Option (Cert S)} (DH : DHyps S oc) {k p1 p2 : Nat}
    {counter : Option (Nat × Nat)} {q : Proto} {c' : Cursor} {cache' : Cache}
    {dr' : List DroppedStore} (hk : k < S.r.protos.size)
    (hq : S.r.protos[k] = { q with pos := p1, counter })
    (hpad : PadRead S.body (S.start k) p1) (hctr : CounterRead S.fr S.body p1 counter p2)
    (hpr : ProtoRead S.fr S.ro (some S.targets).isSome S.body p2
      (if (some S.targets).any (sortedContains · p1) then { pe := S.fr.mode.pe } else S.cache k)
      (S.dr k) (S.args k) q c' cache' dr')
    (hnop : NopRead S.fr S.callSites S.body q c'.pos (S.start (k + 1)))
    (hcache : S.cache (k + 1) = cache') (htable : HdlTables S)
    (hbody : S.c.inRegion k = false) (hncl : NotCleanup S k) :
    DInsnSimAt S oc k := by
  intro s x hs hdi hsafe
  obtain ⟨P, xh, hg, ⟨hfR, hat⟩, ha, hkr⟩ := hdi
  have hf := hfR.1
  have hp1 : posOf S.r k = p1 := by rw [posOf_eq hk, hq]
  have hpr : ProtoRead S.fr S.ro true S.body p2 (S.used k) (S.dr k) (S.args k) q c' cache' dr' := by
    have e : (if (some S.targets).any (sortedContains · p1) then ({ pe := S.fr.mode.pe } : Cache)
        else S.cache k) = S.used k := by simp [Setup.used, Setup.fr, hp1, Option.any]
    rw [e] at hpr
    exact hpr
  have hb0 := boundary_start hD hf.code (prologue_dec hD) k (Nat.le_of_lt hk)
  have hargs : S.args (k + 1) = (S.args k && q.op == .arg) := by
    have := hD.argsSucc k (by simpa using hk)
    simpa [hq] using this
  have hinsn : ∃ i, S.c.d.insns[k]? = some i ∧ ∀ hk : k < S.r.protos.size,
      InsnOf (posOf S.r) S.r.protos[k] i := by
    have h1 := (reducedOf_insns hD.reduced)
    have hk' : k < S.c.d.insns.size := h1.1 ▸ hk
    exact ⟨S.c.d.insns[k], by simp [hk'], fun hk => h1.2 k hk hk'⟩
  have hkn : s.pc < S.c.d.insns.size := by
    rw [hs]; exact (reducedOf_insns hD.reduced).1 ▸ hk
  -- The body, from `p2` with the cache `used k`.
  have body : ∀ (hb2 : Boundary S.rs p2), DBodySim S oc k p2 (S.used k) := fun hb2 => by
    have hPF : ProtoFacts S k p2 q c' cache' :=
      ⟨hk, ⟨p1, counter, by simp [hk, hq]⟩, hinsn, hb2, fun _ => hnop, fun _ => hcache, hargs, hbody, hncl⟩
    by_cases hni : InlineAt S k
    · generalize ha' : S.args k = a at hpr
      cases hpr with
      | inline hn hc h => exact dbodySim_inline hD H DH hPF hn hc h
      | arg h =>
        refine absurd hni (not_inlineAt_of_class hPF (.inl ?_))
        obtain ⟨a, d, hq, -⟩ := argInsn_bounds h
        rw [hq]
        exact classOf_arg
      | call hn h =>
        refine absurd hni (not_inlineAt_of_class hPF (.inl ?_))
        cases callInsn_read h with
        | call hhead => exact callHead_classOf hhead
        | tail hhead => exact tailHead_classOf hhead
      | insn hn hc hi h =>
        refine absurd hni (not_inlineAt_of_class hPF ?_)
        rcases insn_split h with hd | ⟨-, hcore⟩
        · obtain ⟨w, -, hh⟩ := denseSwitch_some hd
          exact .inr hh
        · cases insnCore_read hcore with
          | handler => exact .inr rfl
          | ret => exact .inl classOf_ret
          | unreachable => exact .inl classOf_unreachable
          | jmp => exact .inl classOf_jmp
          | island => exact .inl classOf_island
          | resume => exact .inr rfl
          | dense hd =>
            obtain ⟨w, -, hh⟩ := denseSwitch_some hd
            exact .inr hh
    · exact dbodySim_noninline hD H DH hPF hpr htable hni
  -- The padding's code, in the real machine's memory (`dinv_shadow`).
  have hfx := dinv_shadow H hg hfR ha hkn
  obtain ⟨ns, hns, hcode, hp1e, hb1⟩ := padRead_codeAt hfx.1.code hpad hb0
  rw [setup_virt_mem] at hcode
  -- From `p1`, the ghost with the cache `used k`; the counter check runs on the real machine
  -- related to the shadow, the ghost re-chosen after it (the cache there is empty).
  have from_p1 : ∀ y P' yh, GhostOk S oc s P' → KrOk S oc s P' → FrameInvR S s yh →
      XAgree S P' y yh → yh.rip = addrAt S.ctx p1 → CacheInv (S.used k) (S.virt yh) →
      Reach S.ctx S.E (DNext S oc s) y := by
    intro y P' yh hg' hkr' hfy hay hry hcy
    cases hctr with
    | none => exact body hb1 s y P' yh hs hg' hkr' hfy hay hry hcy hsafe
    | check hcnt hd =>
      have hb2 := (hfy.1.code.dec hd hb1).2.2
      have huk : S.used k = { pe := S.c.mode.pe } :=
        ((ctr_apart hD H).heads k hk (by simp [hq])).1
      refine reach_counter hD H hk (by rw [hq]) (.check hcnt hd) hb1
        (s := shadowOf oc s P') (by rw [shadowOf_pc]; exact hs) (dinv_shadow H hg' hfy hay hkn)
        (hay.2.2.2.1.trans hry) (by rw [huk]; exact CacheInv.emptyPe _ _) ?_
      intro z hfz hrz _
      obtain ⟨P2, zh, hg2, hkr2, hfz2, haz, hzr, hcz⟩ :=
        dinv_at (dinv_reghost H hg' hkr' hkn hfz (by rw [hs]; exact huk)) z rfl rfl rfl rfl
      have hcz' : CacheInv (S.used k) (S.virt zh) := by
        rw [← hs]; exact hcz (by rw [hs]; exact huk)
      exact body hb2 s z P2 zh hs hg2 hkr2 hfz2 haz (hzr.trans hrz) hcz' hsafe
  rcases hat with ⟨hrip, hci⟩ | ⟨hrip, hci⟩
  · rw [hs] at hrip hci
    refine reach_padding_fl hns hcode (ha.2.2.2.1.trans hrip) fun y h1 h2 h3 h4 h5 => ?_
    have hcy : CacheInv (S.used k) (S.virt xh) := by
      unfold Setup.used
      split
      · exact CacheInv.emptyPe _ _
      · exact hci
    exact from_p1 y P (xh.jump y.rip) hg hkr (frameInvR_jump _ hfR) (xAgree_jump ha h1 h2 h3 h4)
      (by show y.rip = _; rw [h5, ← hp1e]) (cacheInv_jump _ hcy)
  · rw [hs, hp1] at hrip
    rw [hs] at hci
    exact from_p1 x P xh hg hkr hfR ha hrip hci

/-- T6: an iteration that reads a dropped store with no code (`Iter.empty`): the ghost runs the
store, the real machine nothing (`kept = []`, `link_inline_drop`). -/
theorem dinsn_empty (hD : Decodes S code relocs rodata callSites dropped scopes mode)
    (H : Hyps S) {oc : Option (Cert S)} (DH : DHyps S oc) {k : Nat} (hk : k < S.r.protos.size)
    {d : DroppedStore} {dr : List DroppedStore} (hdr : S.dr k = d :: dr) (hd : d.at_ = S.start k)
    {q : Proto} {c' : Cursor} {cache' : Cache} {dr' : List DroppedStore}
    (hpk : S.r.protos[k] = { q with pos := S.start k })
    (hr : (inlineInsn (S.cache k) (d :: dr) true).run (atPos S.body (S.start k)) =
      .ok (some (q, cache', dr'), c'))
    (hst1 : S.start (k + 1) = c'.pos) (hca1 : S.cache (k + 1) = cache')
    (hbody : S.c.inRegion k = false) (hncl : NotCleanup S k) :
    DInsnSimAt S oc k := by
  intro s x hs hdi hsafe
  obtain ⟨P, xh, hg, ⟨hfR, hat⟩, ha, hkr⟩ := hdi
  have hf := hfR.1
  have hp1 : posOf S.r k = S.start k := by rw [posOf_eq hk, hpk]
  have hused : S.used k = S.cache k := by
    have hnt := DH.emptyNotTarget k hk d dr hdr hd
    simp [Setup.used, hp1, hnt]
  -- The iteration's `ProtoFacts` (no padding, counter or `nop`: it starts at `S.start k`).
  have hinsn : ∃ i, S.c.d.insns[k]? = some i ∧ ∀ hk : k < S.r.protos.size,
      InsnOf (posOf S.r) S.r.protos[k] i := by
    have h1 := (reducedOf_insns hD.reduced)
    have hk' : k < S.c.d.insns.size := h1.1 ▸ hk
    exact ⟨S.c.d.insns[k], by simp [hk'], fun hk => h1.2 k hk hk'⟩
  have hargs : S.args (k + 1) = (S.args k && q.op == .arg) := by
    have := hD.argsSucc k (by simpa using hk)
    simpa [hpk] using this
  have hnop : NopRead S.fr S.callSites S.body q c'.pos (S.start (k + 1)) := by
    rw [hst1]
    exact .none (by simp [nopAfter, inline_read_bare hr])
  have hP : ProtoFacts S k (S.start k) q c' cache' :=
    ⟨hk, ⟨S.start k, q.counter, by simp [hk, hpk]⟩, hinsn,
      boundary_start hD hf.code (prologue_dec hD) k (Nat.le_of_lt hk), fun _ => hnop, fun _ => hca1, hargs, hbody,
      hncl⟩
  have hcro : CacheRegsOk S (S.cache k) := by
    have := CacheRegs.cacheRegsOk_of_decodes hD k (by rw [Array.length_toList]; exact Nat.le_of_lt hk)
    rw [hused] at this
    exact this
  rw [← hdr] at hr
  have core := dbodySim_inline_at hD H DH hcro hused.symm hP hr
  rcases hat with ⟨hrip, hci⟩ | ⟨hrip, hci⟩
  · rw [hs] at hrip hci
    exact core s x P xh hs hg hkr hfR ha hrip hci hsafe
  · rw [hs, hp1] at hrip
    rw [hs, hused] at hci
    exact core s x P xh hs hg hkr hfR ha hrip hci hsafe

/-- T6: past the instructions R's step fails (`insnSim_oob`). -/
theorem dinsn_oob (hD : Decodes S code relocs rodata callSites dropped scopes mode)
    {oc : Option (Cert S)} {k : Nat} (hk : S.r.protos.size ≤ k) : DInsnSimAt S oc k := by
  intro s x hs _ hsafe
  have hsz := (reducedOf_insns hD.reduced).1
  have hnone : S.c.d.insns[s.pc]? = none := by
    simp only [Array.getElem?_eq_none_iff]; omega
  obtain ⟨m, hm⟩ := hsafe.1 {} _ (by simp [R.step, hnone, OpSem.illFormed]; rfl)
  cases hm

/-- **`decode_sound` on `DInv`** (T6): as `decode_sound`, without `Hyps.deadStore`, for code
without a PE pad region (`hnr`; `DInv` is `BInv`-based: the region needs `RBInv`'s ghost). -/
theorem decode_sound_d (hD : Decodes S code relocs rodata callSites dropped scopes mode)
    (H : Hyps S) (htc : tablesCheck code relocs rodata callSites dropped scopes mode = true)
    {oc : Option (Cert S)} (DH : DHyps S oc) (hnr : ∀ k, S.c.inRegion k = false) :
    ∀ s x, DInv S oc s x → SafeFrom S.Safe S.c s →
      FnSim S.ctx S.E S.c (DInv S oc) (ExitRel S) s x := by
  have htable : HdlTables S := DecodeLink.Tables.hdlTables_of_check hD htc
  refine fnSim_of_insnSim _ _ _ _ _ _ fun s x hdi hsafe => ?_
  by_cases hk : s.pc < S.r.protos.size
  · -- No pad region: no instruction unwinds to a cleanup pad (`RegionFacts.pads`).
    have hnc : NoPeClean S s.pc := fun hpe pad hcl => by
      have h := hD.region.pads s.pc pad hpe hcl
      rw [hnr pad] at h
      cases h
    obtain ⟨_, _, _, hbi, _⟩ := id hdi
    have hncl : NotCleanup S s.pc :=
      notCleanup_of (H.cleansLinked hD hbi.1.1.code.small) hnc
    have hit := hD.itersB s.pc (by simpa using hk) (hnr _)
    simp only [Array.getElem_toList] at hit
    generalize hpk : S.r.protos[s.pc] = pk at hit
    generalize hdr : S.dr s.pc = drk at hit
    generalize hst1 : S.start (s.pc + 1) = st1 at hit
    generalize hca1 : S.cache (s.pc + 1) = ca1 at hit
    generalize hdr1 : S.dr (s.pc + 1) = dr1 at hit
    cases hit with
    | empty hd hr =>
      exact dinsn_empty hD H DH hk hdr hd hpk hr hst1 hca1 (hnr s.pc) hncl s x rfl hdi hsafe
    | main hpad hctr hpr hnop =>
      rw [← hdr] at hpr
      rw [← hst1] at hnop
      exact dinsn_main hD H DH hk hpk hpad hctr hpr hnop hca1 htable (hnr s.pc) hncl s x rfl hdi
        hsafe
  · exact dinsn_oob hD (Nat.le_of_not_lt hk) s x rfl hdi hsafe

end

/-- T7: the checked decoder accepted every dropped store (`decodeChecked`'s last check). -/
theorem decodeChecked_dropped {code : ByteArray} {relocs : Array Reloc} {rodata : ByteArray}
    {callSites : Array CallSite} {dropped : Array DroppedStore} {scopes : Array R.Scope}
    {mode : Ryo.Obj.Mode} {facts : Frame.Facts} {d : Decoded}
    (h : Frame.decodeChecked code (.relocs relocs) rodata callSites dropped scopes mode facts =
      .ok d) :
    Frame.droppedNotDead d mode facts = .ok [] := by
  unfold Frame.decodeChecked Frame.decodeChecked.checkDropped at h
  cases hb : decodeBounded code (.relocs relocs) rodata callSites dropped scopes mode with
  | error e => simp [hb, bind, Except.bind, throw, throwThe, MonadExceptOf.throw] at h
  | ok d0 =>
    cases hfs : frameSizesCheck d0 mode with
    | false => simp [hb, hfs, bind, Except.bind, pure, Except.pure, throw, throwThe,
        MonadExceptOf.throw] at h
    | true =>
    cases hpc : privCheck d0 with
    | false => simp [hb, hfs, hpc, bind, Except.bind, pure, Except.pure, throw, throwThe,
        MonadExceptOf.throw] at h
    | true =>
    cases hsd : spDispCheck code.data d0 mode with
    | false => simp [hb, hfs, hpc, hsd, bind, Except.bind, pure, Except.pure, throw, throwThe,
        MonadExceptOf.throw] at h
    | true =>
    cases ht : tablesCheck code relocs rodata callSites dropped scopes mode with
    | false => simp [hb, hfs, hpc, hsd, ht, bind, Except.bind, pure, Except.pure, throw, throwThe,
        MonadExceptOf.throw] at h
    | true =>
    cases hcs : callSitesCheck code relocs rodata callSites dropped scopes mode with
    | false => simp [hb, hfs, hpc, hsd, ht, hcs, bind, Except.bind, pure, Except.pure, throw,
        throwThe, MonadExceptOf.throw] at h
    | true =>
    cases hri : relocsInCheck code.data relocs with
    | false => simp [hb, hfs, hpc, hsd, ht, hcs, hri, bind, Except.bind, pure, Except.pure, throw,
        throwThe, MonadExceptOf.throw] at h
    | true =>
    cases hcc : cacheClearedCheck code relocs rodata callSites dropped scopes mode with
    | false => simp [hb, hfs, hpc, hsd, ht, hcs, hri, hcc, bind, Except.bind, pure, Except.pure,
        throw, throwThe, MonadExceptOf.throw] at h
    | true =>
    cases hal : argsLeadCheck code relocs rodata callSites dropped scopes mode with
    | false => simp [hb, hfs, hpc, hsd, ht, hcs, hri, hcc, hal, bind, Except.bind, pure,
        Except.pure, throw, throwThe, MonadExceptOf.throw] at h
    | true =>
      cases hdn : Frame.droppedNotDead d0 mode facts with
      | error e => simp [hb, hfs, hpc, hsd, ht, hcs, hri, hcc, hal, hdn, bind, Except.bind, pure,
          Except.pure] at h
      | ok l =>
        cases l with
        | nil =>
          simp [hb, hfs, hpc, hsd, ht, hcs, hri, hcc, hal, hdn, bind, Except.bind, pure,
            Except.pure] at h
          subst h
          exact hdn
        | cons k rest =>
          simp [hb, hfs, hpc, hsd, ht, hcs, hri, hcc, hal, hdn, bind, Except.bind, pure,
            Except.pure, throw, throwThe, MonadExceptOf.throw] at h

/-- The certificate, if the code has dropped stores. -/
noncomputable def certOpt (S : Setup) {facts : Frame.Facts}
    (h : Frame.droppedNotDead S.c.d S.c.mode facts = .ok []) : Option (Cert S) :=
  if hne : S.c.d.dropped.isEmpty = false then some (Cert.ofChecked h hne) else none

theorem certOpt_none {S : Setup} {facts : Frame.Facts}
    (h : Frame.droppedNotDead S.c.d S.c.mode facts = .ok []) :
    certOpt S h = none → S.c.d.dropped.isEmpty = true := by
  intro hc
  unfold certOpt at hc
  split at hc
  · cases hc
  · rename_i hne
    cases hb : S.c.d.dropped.isEmpty
    · exact absurd hb hne
    · rfl

theorem certOpt_facts {S : Setup} {facts : Frame.Facts}
    (h : Frame.droppedNotDead S.c.d S.c.mode facts = .ok []) :
    ∀ C, certOpt S h = some C → C.facts = facts := by
  intro C hc
  unfold certOpt at hc
  split at hc
  · cases hc
    rfl
  · cases hc

end Ryo.Proofs.DeadStore
