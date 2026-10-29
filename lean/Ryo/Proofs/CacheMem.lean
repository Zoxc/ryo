/-
Ryo.Proofs.CacheMem — one R step of a `load`, `store` or rip-relative address instruction
(`addrConst`, `addrSym`, `addrSymInd`) against its sequence, on `rax` and as the register
cache emits it (aot.md §C2 "Inline sequences", "Register cache"): the classes
`inline_step_cached` (`Ryo/Proofs/CacheStep.lean`) leaves out, as they have `Sound` only with
more hypotheses (`sound_load`, `sound_store`: `Inline/Mem.lean`; `inline_sound_rip`:
`Inline.lean`, from `Inline/Rip.lean`).

- `step_of`: `inline_step`'s argument with the class's soundness replaced by `hrun`, what the
  sequence gives after the scopes and `opSem` (`RRel` with the new state, a predicate `P`,
  `rip`, the control `CtlOk`).
- `load_step`, `store_step`, `rip_step`: the R step against the sequence on `rax`. `load` and
  `store` keep `MemRel`; the scopes keep it (`memRel_foldlM`, scopes below `2^62` bytes), so it
  is assumed of `s`. `WrApart` (load), `FrameApart`, `MemDisjoint` (store), `Private` and
  `Globals` are assumed of the state after the scopes (`AfterScopes`). A store's `RRel` after
  needs its allocation count kept (`store_allocs`: `store` sets one allocation).
- `load_step_sep`, `store_step_sep`, `rip_step_sep` (and `_cached`): the same from facts before
  the scopes: `FrameSep` over a frame window (kept by the scopes, `ScopeMem`, and given back
  after the step when its frame writes lie in the window, `WrIn`), `Globals`' layout part and
  `MemRel` (`afterScopes_globals`); `Private` stays a hypothesis after the scopes
  (`afterScopes_private` gives it from before them). `FrameBounds.lean` derives the window
  facts from one property of the decoded code.
- `cached_of`: from a run of the sequence on every `swapS xr x` (`xr` the register `emit`
  picks), a run of `emit`'s output from `x` with `CacheInv` after, for any conclusion `Q` that
  sees only `rbp`, memory and flags (`inline_step_cached`'s argument).
- `load_step_cached`, `store_step_cached`, `rip_step_cached`: through the cache, with
  `CacheInv (cache.emit cand).2` after: the cache as the decoder leaves it (`inlineInsn`'s
  `accept`). A store through a pointer clears every entry inside `emit` (`update`'s `write`
  drops all entries for a base other than `rbp`), so no separate clearing point is needed;
  `CacheInv` follows from `update_inv`, as for the other classes.

Left as hypotheses: `InlineOk f cls` (discharged by `inlineOps_ok`, `RyoProofs/InlineOk.lean`,
for `(f, cls) ∈ inlineOps`), `ripAddr cls` for the rip classes (by `decide` once `cls` is
known); `Private` of a `load`'s destination; `MemRel` after a rip-relative address step (its
frame write is like `load`'s, but isn't proved here).
-/
import Ryo.Proofs.CacheStep
import Ryo.Proofs.ScopeMem

set_option linter.constructorNameAsVariable false

namespace Ryo.Proofs.CacheMem

open Ryo.Spec Ryo.Vm Ryo.Vm.OpSem Ryo.X86 Ryo.Vm.Asm Ryo.Proofs.Inline Ryo.Proofs.Scope
  Ryo.Proofs.Step Ryo.Proofs.RegCache Ryo.Proofs.CacheStep Ryo.Proofs.ScopeMem

/-- `P` of every state the scopes before `s.pc` reach from `s`. -/
def AfterScopes (c : R.Code) (s : R.RState) (P : OpSem.State → Prop) : Prop :=
  ∀ s1, (c.scopesAt s.pc).foldlM R.applyScope s = .ok s1 → P s1.st

/-- The next instruction: the fall-through, or for a branch class the target exactly when the
sequence's condition holds on `x`'s flags (`inline_step`'s last conclusion). -/
def BrOk (f : Full.Opcode) (ops : List (R.Opnd Nat)) (s s' : R.RState) :
    Option Cond → X86.State → Prop
  | none, _ => s'.pc = s.pc + 1
  | some cond, x => ∃ neg t b, R.nativeCtl f ops = some (.branch neg t) ∧
      cond.eval x.flags = .ok b ∧ s'.pc = if b then t else s.pc + 1

/-- The control `opSem` returned, against the sequence's condition on `x`'s flags (`Post.ctl`). -/
def CtlOk (f : Full.Opcode) (ops : List (R.Opnd Nat)) : Option Cond → Control → X86.State → Prop
  | none, ctl, _ => ctl = .next
  | some cond, ctl, x => ∃ b, ctl = .branch b ∧
      ∀ neg t, R.nativeCtl f ops = some (.branch neg t) → cond.eval x.flags = .ok (b != neg)

theorem rbp_of_regs {x x' : X86.State} (h : ∀ i : Fin 16, i ≠ 0 → i ≠ 1 → x'.regs i = x.regs i) :
    x'.reg .rbp = x.reg .rbp :=
  h 5 (by decide) (by decide)

/-- The step, given what the sequence does after the scopes and `opSem` (see the module
comment). -/
theorem step_of (ctx : Ctx) {P : OpSem.State → X86.State → Prop} {c : R.Code} {s s' : R.RState}
    {x : X86.State} {ch : OpSem.Choice} {op : Reduced.Opcode} {ops : List (R.Opnd Nat)}
    {f : Full.Opcode} {cls : Class} {items : List Item} {br : Option Cond} (hr : RRel s x)
    (hi : c.d.insns[s.pc]? = some (.native op ops)) (hf : op.full = some f)
    (hok : InlineOk f cls) (h : R.step c s ch = .ok (.step s'))
    (hrun : ∀ s1 vals st' ctl, (c.scopesAt s.pc).foldlM R.applyScope s = .ok s1 → RRel s1 x →
      nativeVals c.ρ f ops = some vals → opSem f vals s1.st ch = .ok (ctl, st') →
      ∃ x', execItems ctx items x = .ok x' ∧ Rel st' x' ∧ x'.reg .rbp = x.reg .rbp ∧
        EscWF st' ∧ P st' x' ∧ x'.rip = x.rip + BitVec.ofNat 64 (items.map Item.size).sum ∧
        CtlOk f ops br ctl x') :
    ∃ x', execItems ctx items x = .ok x' ∧ RRel s' x' ∧ P s'.st x' ∧
      x'.rip = x.rip + BitVec.ofNat 64 (items.map Item.size).sum ∧
      BrOk f ops s s' br x' := by
  obtain ⟨s1, hsc, hv⟩ := step_native hi hf hok.opShape h
  have hr1 := rrel_scopes hr hsc
  have hpc : s1.pc = s.pc := (scopes_keeps _ hsc).pc
  obtain ⟨vals, t, ctl, st', pc', hn, hc, ho, hp, hs'⟩ :=
    stepView_native hf hok.opShape hok.notResume hok.notUnreachable hv
  cases hs'
  obtain ⟨x', hx, hrel, hb, hw, hP, hrip, hctl⟩ := hrun s1 vals st' ctl hsc hr1 hn ho
  refine ⟨x', hx, ⟨hrel, by rw [hb]; exact hr1.rbp, hw⟩, hP, hrip, ?_⟩
  cases br with
  | none =>
    simp only [CtlOk, BrOk] at hctl ⊢
    subst hctl
    cases t <;> simp [R.Then.succ] at hp
    rw [← hp, hpc]
  | some cond =>
    simp only [CtlOk, BrOk] at hctl ⊢
    obtain ⟨b, rfl, hb⟩ := hctl
    cases t with
    | branch neg tt =>
      refine ⟨neg, tt, b != neg, hc, hb neg tt hc, ?_⟩
      simp only [R.Then.succ, Option.some.injEq] at hp
      rw [← hp, hpc]
    | _ => simp [R.Then.succ] at hp

theorem ctlOk_of_post {f : Full.Opcode} {ops : List (R.Opnd Nat)} {vals : Operands}
    {items : List Item} {br : Option Cond} {st st' : OpSem.State} {ctl : Control}
    {x x' : X86.State} (h : Post f ops vals items br st st' ctl x x') : CtlOk f ops br ctl x' := by
  have := h.ctl
  cases br <;> exact this

/-! ### The R steps -/

/-- One R step of a `load` against its sequence (see the module comment). -/
theorem load_step (ctx : Ctx) {c : R.Code} {s s' : R.RState} {x : X86.State}
    {ch : OpSem.Choice} {op : Reduced.Opcode} {ops : List (R.Opnd Nat)} {f : Full.Opcode}
    {w : W} {items : List Item} {br : Option Cond} (hr : RRel s x) (hm : MemRel s.st x)
    (hsz : ∀ sc ∈ c.scopesAt s.pc, sc.size < 2 ^ 62)
    (hap : ∀ vals, nativeVals c.ρ f ops = some vals → AfterScopes c s (WrApart f vals · x))
    (hpriv : ∀ vals, nativeVals c.ρ f ops = some vals → AfterScopes c s (Private f vals))
    (hi : c.d.insns[s.pc]? = some (.native op ops)) (hf : op.full = some f)
    (hok : InlineOk f (.load w)) (hseq : sequence (.load w) ops = some (items, br))
    (h : R.step c s ch = .ok (.step s')) :
    ∃ x', execItems ctx items x = .ok x' ∧ RRel s' x' ∧ MemRel s'.st x' ∧
      x'.rip = x.rip + BitVec.ofNat 64 (items.map Item.size).sum ∧
      BrOk f ops s s' br x' := by
  refine step_of (P := MemRel) ctx hr hi hf hok h fun s1 vals st' ctl hsc hr1 hn ho => ?_
  have hm1 := (memRel_foldlM _ hsz hr hm hsc).2
  obtain ⟨x', hx, hpost, hm'⟩ := sound_load w ctx c.ρ f ops items br vals s1.st st' ctl ch x
    hok.shape hseq hn ho hr1.rel (hpriv vals hn s1 hsc) hm1 (hap vals hn s1 hsc)
  exact ⟨x', hx, hpost.rel, rbp_of_regs hpost.regs, escWF_of_sameButWrites hr1.wf hpost.same,
    hm', hpost.rip, ctlOk_of_post hpost⟩

/-- A store keeps the number of allocations and the escaped objects. -/
theorem store_allocs {ρ : R.Addrs} {f : Full.Opcode} {w : W} {ops : List (R.Opnd Nat)}
    {vals : Operands} {st st' : OpSem.State} {ctl : Control} {ch : OpSem.Choice}
    (hs : shapeOk f (.store w) = true) (hv : nativeVals ρ f ops = some vals)
    (hsem : opSem f vals st ch = .ok (ctl, st')) :
    st'.mem.allocs.size = st.mem.allocs.size ∧ st'.escaped = st.escaped := by
  obtain ⟨⟨r, hh⟩, ho⟩ := shapeOk_spec hs
  simp only [classHandler, classOperands] at hh ho
  obtain ⟨o0, o1, v0, v1, rfl, rfl, h0, h1⟩ := nvs2 ho hv
  obtain ⟨pp, k, rfl, rfl⟩ := nv_mem.1 h0
  obtain ⟨s1, rfl, rfl⟩ := nv_slot.1 h1
  have hty := (tyName_parse w).1
  obtain ⟨bp, q, bs, mem', hrp, hq, hrs, hst, rfl, rfl⟩ := opSem_store hh hty ho hsem
  have hlen := readFrame_length hrs
  have hn0 : bs.length ≠ 0 := by rw [hlen]; cases w <;> decide
  obtain ⟨id, a, -, -, -, -, rfl⟩ := store_ok hn0 hst
  simp

/-- One R step of a `store` against its sequence (see the module comment). -/
theorem store_step (ctx : Ctx) {c : R.Code} {s s' : R.RState} {x : X86.State}
    {ch : OpSem.Choice} {op : Reduced.Opcode} {ops : List (R.Opnd Nat)} {f : Full.Opcode}
    {w : W} {items : List Item} {br : Option Cond} (hr : RRel s x) (hm : MemRel s.st x)
    (hsz : ∀ sc ∈ c.scopesAt s.pc, sc.size < 2 ^ 62) (hap : AfterScopes c s (FrameApart · x))
    (hdis : AfterScopes c s MemDisjoint)
    (hi : c.d.insns[s.pc]? = some (.native op ops)) (hf : op.full = some f)
    (hok : InlineOk f (.store w)) (hseq : sequence (.store w) ops = some (items, br))
    (h : R.step c s ch = .ok (.step s')) :
    ∃ x', execItems ctx items x = .ok x' ∧ RRel s' x' ∧ MemRel s'.st x' ∧
      x'.rip = x.rip + BitVec.ofNat 64 (items.map Item.size).sum ∧
      BrOk f ops s s' br x' := by
  refine step_of (P := MemRel) ctx hr hi hf hok h fun s1 vals st' ctl hsc hr1 hn ho => ?_
  have hm1 := (memRel_foldlM _ hsz hr hm hsc).2
  obtain ⟨rfl, x', hx, hpost⟩ := sound_store w ctx c.ρ f ops items br vals s1.st st' ctl ch x
    hok.shape hseq hn ho hr1.rel hm1 (hap s1 hsc) (hdis s1 hsc)
  obtain ⟨hsize, hesc⟩ := store_allocs hok.shape hn ho
  have hw : EscWF st' := ⟨fun e he => by rw [hesc] at he; rw [hsize]; exact hr1.wf.idLt e he,
    fun e he e' he' hid => by rw [hesc] at he he'; exact hr1.wf.idInj e he e' he' hid⟩
  exact ⟨x', hx, hpost.rel, rbp_of_regs hpost.regs, hw, hpost.memRel, hpost.rip, hpost.ctl⟩

/-- One R step of a rip-relative address (`addrConst`, `addrSym`, `addrSymInd`) against its
sequence (see the module comment). -/
theorem rip_step (ctx : Ctx) {c : R.Code} {s s' : R.RState} {x : X86.State}
    {ch : OpSem.Choice} {op : Reduced.Opcode} {ops : List (R.Opnd Nat)} {f : Full.Opcode}
    {cls : Class} {items : List Item} {br : Option Cond} (hc : ripAddr cls = true)
    (hr : RRel s x) (hg : AfterScopes c s (Globals ctx c.ρ · x))
    (hi : c.d.insns[s.pc]? = some (.native op ops)) (hf : op.full = some f)
    (hok : InlineOk f cls) (hseq : sequence cls ops = some (items, br))
    (h : R.step c s ch = .ok (.step s')) :
    ∃ x', execItems ctx items x = .ok x' ∧ RRel s' x' ∧
      x'.rip = x.rip + BitVec.ofNat 64 (items.map Item.size).sum ∧
      BrOk f ops s s' br x' := by
  obtain ⟨x', hx, hr', -, hrip, hbr⟩ := step_of (P := fun _ _ => True) ctx hr hi hf hok h
    fun s1 vals st' ctl hsc hr1 hn ho => by
      obtain ⟨x', hx, hpost⟩ := inline_sound_rip cls hc ctx c.ρ f ops items br vals s1.st st' ctl
        ch x hok.shape hseq hn ho hr1.rel (hg s1 hsc)
      exact ⟨x', hx, hpost.rel, rbp_of_regs hpost.regs,
        escWF_of_sameButWrites hr1.wf hpost.same, trivial, hpost.rip, ctlOk_of_post hpost⟩
  exact ⟨x', hx, hr', hrip, hbr⟩

/-! ### Through the cache -/

theorem swapS_rbp {xr : Reg} (hb : xr ≠ .rbp) (x : X86.State) :
    (swapS xr x).reg .rbp = x.reg .rbp := by
  have := reg_swapS xr .rbp x
  rwa [show swapR xr .rbp = .rbp by simp [swapR, Ne.symm hb]] at this

theorem memRel_congr {st : OpSem.State} {x y : X86.State} (hm : y.mem = x.mem)
    (h : MemRel st x) : MemRel st y := by
  unfold MemRel; rw [hm]; exact h

theorem frameApart_congr {st : OpSem.State} {x y : X86.State} (hb : y.reg .rbp = x.reg .rbp)
    (h : FrameApart st x) : FrameApart st y := by
  unfold FrameApart fpAddr; rw [hb]; exact h

theorem wrApart_congr {f : Full.Opcode} {vals : Operands} {st : OpSem.State} {x y : X86.State}
    (hb : y.reg .rbp = x.reg .rbp) (h : WrApart f vals st x) : WrApart f vals st y := by
  unfold WrApart fpAddr; rw [hb]; exact h

theorem globals_congr {ctx : Ctx} {ρ : R.Addrs} {st : OpSem.State} {x y : X86.State}
    (hm : y.mem = x.mem) (h : Globals ctx ρ st x) : Globals ctx ρ st y :=
  ⟨h.const, h.data, h.sym, fun p bs hl => hm ▸ h.mem p bs hl⟩

/-- The emitted items from a run of the sequence on every swapped state (see the module
comment). -/
theorem cached_of (ctx : Ctx) {T : Type} {cls : Class} {ops : List (R.Opnd T)} {cand : List Item}
    {br : Option Cond} {cache : Cache} {x : X86.State} {Q : X86.State → Prop}
    (hinv : CacheInv cache x) (hext : ∀ b, cls ≠ .ext .q b true)
    (hseq : sequence cls ops = some (cand, br))
    (hQ : ∀ y z, y.reg .rbp = z.reg .rbp → y.mem = z.mem → y.flags = z.flags → Q z → Q y)
    (hrun : ∀ xr, xr ≠ .rbp → ∃ x1, execItems ctx cand (swapS xr x) = .ok x1 ∧ Q x1) :
    ∃ y, execItems ctx (cache.emit cand).1 x = .ok y ∧ Q y ∧ CacheInv (cache.emit cand).2 y ∧
      y.rip = x.rip + BitVec.ofNat 64 ((cache.emit cand).1.map Item.size).sum := by
  have hok' := sequence_ok2 hext hseq
  have hsafe : ∀ it ∈ cand, cacheSafe it = true := fun it hit => (hok' it hit).1
  generalize hxr : pool[(emitHead { cache with tick := cache.tick + 1 } cand).1]! = xr
  have hb : xr ≠ .rbp := hxr ▸ pool_ne_rbp' _
  have hc : xr ≠ .rcx := hxr ▸ pool_ne_rcx _
  obtain ⟨x1, hx1, hq1⟩ := hrun xr hb
  have hren : ∃ z, execItems ctx (cand.map (ren xr)) x = .ok z ∧
      z.reg .rbp = x1.reg .rbp ∧ z.mem = x1.mem ∧ z.flags = x1.flags := by
    by_cases hq : ∃ it ∈ cand, isMulQ it = true
    · have hx : xr = .rax := by rw [← hxr, emitHead_mulQ _ _ hq]; rfl
      subst hx
      have hs0 : swapS .rax x = x := by
        cases x; simp only [swapS, X86.State.mk.injEq, and_true]
        funext i; simp only [swapI]; split <;> simp_all
      rw [hs0] at hx1
      refine ⟨x1, ?_, rfl, rfl, rfl⟩
      rw [List.map_congr_left (fun it _ => ren_rax it), List.map_id']
      exact hx1
    · have hm : ∀ it ∈ cand, cacheSafe it = true ∧ isMulQ it = false ∧ onlyARB it = true :=
        fun it hit => ⟨hsafe it hit, by cases e : isMulQ it; rfl; exact absurd ⟨it, hit, e⟩ hq,
          (hok' it hit).2.resolve_right hq⟩
      obtain ⟨z, hz, hze⟩ := execItems_swap ctx hc hb cand (swapS xr x) x1 x.rip hm hx1
      rw [swapS_swapS, jump_rip] at hz
      refine ⟨z, ?_, ?_, ?_, ?_⟩
      · rw [List.map_congr_left (fun it hit => ren_eq_swap hc hb ((hok' it hit).2.resolve_right hq))]
        exact hz
      · rw [hze]
        show (swapS xr x1).reg .rbp = _
        exact swapS_rbp hb x1
      · rw [hze]; rfl
      · rw [hze]; rfl
  obtain ⟨z, hz, hzb, hzm, hzf⟩ := hren
  obtain ⟨y, hy, hyz, hcy⟩ := emit_sound hinv hsafe (hxr ▸ hz)
  have hyb : y.reg .rbp = x1.reg .rbp := by rw [hyz]; exact hzb
  have hym : y.mem = x1.mem := by rw [hyz]; exact hzm
  have hyf : y.flags = x1.flags := by rw [hyz]; exact hzf
  exact ⟨y, hy, hQ y x1 hyb hym hyf hq1, hcy, execItems_rip ctx _ x y (emit_safe hinv.1 hsafe) hy⟩

/-- `swapI xr` fixes the indices other than `rax`'s and `xr`'s. -/
theorem swapI_other {xr : Reg} {i : Fin 16} (h0 : i ≠ 0) (hx : i ≠ xr.idx) : swapI xr i = i := by
  have ha : Reg.rax.idx = 0 := rfl
  unfold swapI
  rw [ha]
  simp only [h0, hx, ↓reduceIte]

/-- `cached_of`, also keeping the registers: when every run of the sequence (on the swapped state)
keeps the registers outside `Clob` (which holds `rax`), the emitted run keeps those outside
`Clob` and the register `emit` computes in. -/
theorem cached_of_regs (ctx : Ctx) {T : Type} {cls : Class} {ops : List (R.Opnd T)}
    {cand : List Item} {br : Option Cond} {cache : Cache} {x : X86.State} {Q : X86.State → Prop}
    {Clob : Fin 16 → Prop} (h0 : Clob 0)
    (hinv : CacheInv cache x) (hext : ∀ b, cls ≠ .ext .q b true)
    (hseq : sequence cls ops = some (cand, br))
    (hQ : ∀ y z, y.reg .rbp = z.reg .rbp → y.mem = z.mem → y.flags = z.flags → Q z → Q y)
    (hrun : ∀ xr, xr ≠ .rbp → ∃ x1, execItems ctx cand (swapS xr x) = .ok x1 ∧ Q x1 ∧
      ∀ i, ¬ Clob i → x1.regs i = (swapS xr x).regs i) :
    ∃ y, execItems ctx (cache.emit cand).1 x = .ok y ∧ Q y ∧ CacheInv (cache.emit cand).2 y ∧
      y.rip = x.rip + BitVec.ofNat 64 ((cache.emit cand).1.map Item.size).sum ∧
      ∀ i, ¬ Clob i → i ≠ (pool[(emitHead { cache with tick := cache.tick + 1 } cand).1]!).idx →
        y.regs i = x.regs i := by
  have hok' := sequence_ok2 hext hseq
  have hsafe : ∀ it ∈ cand, cacheSafe it = true := fun it hit => (hok' it hit).1
  generalize hxr : pool[(emitHead { cache with tick := cache.tick + 1 } cand).1]! = xr
  have hb : xr ≠ .rbp := hxr ▸ pool_ne_rbp' _
  have hc : xr ≠ .rcx := hxr ▸ pool_ne_rcx _
  obtain ⟨x1, hx1, hq1, hr1⟩ := hrun xr hb
  have hn0 : ∀ i, ¬ Clob i → i ≠ 0 := fun i hi he => hi (he ▸ h0)
  have hren : ∃ z, execItems ctx (cand.map (ren xr)) x = .ok z ∧
      z.reg .rbp = x1.reg .rbp ∧ z.mem = x1.mem ∧ z.flags = x1.flags ∧
      ∀ i, ¬ Clob i → i ≠ xr.idx → z.regs i = x.regs i := by
    by_cases hq : ∃ it ∈ cand, isMulQ it = true
    · have hx : xr = .rax := by rw [← hxr, emitHead_mulQ _ _ hq]; rfl
      subst hx
      have hs0 : swapS .rax x = x := by
        cases x; simp only [swapS, X86.State.mk.injEq, and_true]
        funext i; simp only [swapI]; split <;> simp_all
      rw [hs0] at hx1 hr1
      refine ⟨x1, ?_, rfl, rfl, rfl, fun i hi _ => hr1 i hi⟩
      rw [List.map_congr_left (fun it _ => ren_rax it), List.map_id']
      exact hx1
    · have hm : ∀ it ∈ cand, cacheSafe it = true ∧ isMulQ it = false ∧ onlyARB it = true :=
        fun it hit => ⟨hsafe it hit, by cases e : isMulQ it; rfl; exact absurd ⟨it, hit, e⟩ hq,
          (hok' it hit).2.resolve_right hq⟩
      obtain ⟨z, hz, hze⟩ := execItems_swap ctx hc hb cand (swapS xr x) x1 x.rip hm hx1
      rw [swapS_swapS, jump_rip] at hz
      refine ⟨z, ?_, ?_, ?_, ?_, ?_⟩
      · rw [List.map_congr_left (fun it hit => ren_eq_swap hc hb ((hok' it hit).2.resolve_right hq))]
        exact hz
      · rw [hze]
        show (swapS xr x1).reg .rbp = _
        exact swapS_rbp hb x1
      · rw [hze]; rfl
      · rw [hze]; rfl
      · intro i hi hix
        have hsw := swapI_other (hn0 i hi) hix
        have e1 : z.regs i = x1.regs (swapI xr i) := by rw [hze]; rfl
        have e2 : (swapS xr x).regs i = x.regs (swapI xr i) := rfl
        rw [e1, hsw, hr1 i hi, e2, hsw]
  obtain ⟨z, hz, hzb, hzm, hzf, hzr⟩ := hren
  obtain ⟨y, hy, hyz, hcy⟩ := emit_sound hinv hsafe (hxr ▸ hz)
  have hyb : y.reg .rbp = x1.reg .rbp := by rw [hyz]; exact hzb
  have hym : y.mem = x1.mem := by rw [hyz]; exact hzm
  have hyf : y.flags = x1.flags := by rw [hyz]; exact hzf
  have hyr : y.regs = z.regs := by rw [hyz]; rfl
  exact ⟨y, hy, hQ y x1 hyb hym hyf hq1, hcy, execItems_rip ctx _ x y (emit_safe hinv.1 hsafe) hy,
    fun i hi hix => by rw [hyr]; exact hzr i hi hix⟩

/-- The step's conclusion on the control, kept by equal flags. -/
theorem brOk_congr {f : Full.Opcode} {ops : List (R.Opnd Nat)} {s s' : R.RState}
    {y z : X86.State} {br : Option Cond} (hf : y.flags = z.flags) (h : BrOk f ops s s' br z) :
    BrOk f ops s s' br y := by
  cases br with
  | none => exact h
  | some cond => simp only [BrOk, hf] at h ⊢; exact h

/-- `load_step` through the register cache (see the module comment). -/
theorem load_step_cached (ctx : Ctx) {c : R.Code} {s s' : R.RState} {x : X86.State}
    {ch : OpSem.Choice} {op : Reduced.Opcode} {ops : List (R.Opnd Nat)} {f : Full.Opcode}
    {w : W} {cand : List Item} {br : Option Cond} {cache : Cache} (hinv : CacheInv cache x)
    (hr : RRel s x) (hm : MemRel s.st x)
    (hsz : ∀ sc ∈ c.scopesAt s.pc, sc.size < 2 ^ 62)
    (hap : ∀ vals, nativeVals c.ρ f ops = some vals → AfterScopes c s (WrApart f vals · x))
    (hpriv : ∀ vals, nativeVals c.ρ f ops = some vals → AfterScopes c s (Private f vals))
    (hi : c.d.insns[s.pc]? = some (.native op ops)) (hf : op.full = some f)
    (hok : InlineOk f (.load w)) (hseq : sequence (.load w) ops = some (cand, br))
    (h : R.step c s ch = .ok (.step s')) :
    ∃ x', execItems ctx (cache.emit cand).1 x = .ok x' ∧ RRel s' x' ∧ MemRel s'.st x' ∧
      CacheInv (cache.emit cand).2 x' ∧
      x'.rip = x.rip + BitVec.ofNat 64 ((cache.emit cand).1.map Item.size).sum ∧
      BrOk f ops s s' br x' := by
  obtain ⟨y, hy, ⟨hr', hm', hbr⟩, hcy, hrip⟩ := cached_of ctx
    (Q := fun y => RRel s' y ∧ MemRel s'.st y ∧ BrOk f ops s s' br y) hinv (fun _ h => by cases h) hseq
    (fun y z hb hm hf hq =>
      ⟨rrel_congr hq.1 hb hm, memRel_congr hm hq.2.1, brOk_congr hf hq.2.2⟩)
    fun xr hb => by
      obtain ⟨x1, hx1, hr1, hm1, -, hbr⟩ := load_step ctx (x := swapS xr x)
        (rrel_congr hr (swapS_rbp hb x) rfl) (memRel_congr rfl hm) hsz
        (fun vals hv s1 h1 => wrApart_congr (swapS_rbp hb x) (hap vals hv s1 h1)) hpriv hi hf hok
        hseq h
      exact ⟨x1, hx1, hr1, hm1, hbr⟩
  exact ⟨y, hy, hr', hm', hcy, hrip, hbr⟩

/-- `store_step` through the register cache (see the module comment): `emit`'s `update` clears
the cache at the store through the pointer. -/
theorem store_step_cached (ctx : Ctx) {c : R.Code} {s s' : R.RState} {x : X86.State}
    {ch : OpSem.Choice} {op : Reduced.Opcode} {ops : List (R.Opnd Nat)} {f : Full.Opcode}
    {w : W} {cand : List Item} {br : Option Cond} {cache : Cache} (hinv : CacheInv cache x)
    (hr : RRel s x) (hm : MemRel s.st x)
    (hsz : ∀ sc ∈ c.scopesAt s.pc, sc.size < 2 ^ 62) (hap : AfterScopes c s (FrameApart · x))
    (hdis : AfterScopes c s MemDisjoint)
    (hi : c.d.insns[s.pc]? = some (.native op ops)) (hf : op.full = some f)
    (hok : InlineOk f (.store w)) (hseq : sequence (.store w) ops = some (cand, br))
    (h : R.step c s ch = .ok (.step s')) :
    ∃ x', execItems ctx (cache.emit cand).1 x = .ok x' ∧ RRel s' x' ∧ MemRel s'.st x' ∧
      CacheInv (cache.emit cand).2 x' ∧
      x'.rip = x.rip + BitVec.ofNat 64 ((cache.emit cand).1.map Item.size).sum ∧
      BrOk f ops s s' br x' := by
  obtain ⟨y, hy, ⟨hr', hm', hbr⟩, hcy, hrip⟩ := cached_of ctx
    (Q := fun y => RRel s' y ∧ MemRel s'.st y ∧ BrOk f ops s s' br y) hinv (fun _ h => by cases h) hseq
    (fun y z hb hm hf hq =>
      ⟨rrel_congr hq.1 hb hm, memRel_congr hm hq.2.1, brOk_congr hf hq.2.2⟩)
    fun xr hb => by
      obtain ⟨x1, hx1, hr1, hm1, -, hbr⟩ := store_step ctx (x := swapS xr x)
        (rrel_congr hr (swapS_rbp hb x) rfl) (memRel_congr rfl hm) hsz
        (fun s1 h1 => frameApart_congr (swapS_rbp hb x) (hap s1 h1)) hdis hi hf hok hseq h
      exact ⟨x1, hx1, hr1, hm1, hbr⟩
  exact ⟨y, hy, hr', hm', hcy, hrip, hbr⟩

/-- `rip_step` through the register cache (see the module comment). -/
theorem rip_step_cached (ctx : Ctx) {c : R.Code} {s s' : R.RState} {x : X86.State}
    {ch : OpSem.Choice} {op : Reduced.Opcode} {ops : List (R.Opnd Nat)} {f : Full.Opcode}
    {cls : Class} {cand : List Item} {br : Option Cond} {cache : Cache} (hc : ripAddr cls = true)
    (hinv : CacheInv cache x) (hr : RRel s x) (hg : AfterScopes c s (Globals ctx c.ρ · x))
    (hi : c.d.insns[s.pc]? = some (.native op ops)) (hf : op.full = some f)
    (hok : InlineOk f cls) (hseq : sequence cls ops = some (cand, br))
    (h : R.step c s ch = .ok (.step s')) :
    ∃ x', execItems ctx (cache.emit cand).1 x = .ok x' ∧ RRel s' x' ∧
      CacheInv (cache.emit cand).2 x' ∧
      x'.rip = x.rip + BitVec.ofNat 64 ((cache.emit cand).1.map Item.size).sum ∧
      BrOk f ops s s' br x' := by
  have hext : ∀ b, cls ≠ .ext .q b true := fun b he => by subst he; simp [ripAddr] at hc
  obtain ⟨y, hy, ⟨hr', hbr⟩, hcy, hrip⟩ := cached_of ctx
    (Q := fun y => RRel s' y ∧ BrOk f ops s s' br y) hinv hext hseq
    (fun y z hb hm hf hq => ⟨rrel_congr hq.1 hb hm, brOk_congr hf hq.2⟩)
    fun xr hb => by
      obtain ⟨x1, hx1, hr1, -, hbr⟩ := rip_step ctx (x := swapS xr x) hc
        (rrel_congr hr (swapS_rbp hb x) rfl)
        (fun s1 h1 => globals_congr (x := x) (st := s1.st) rfl (hg s1 h1)) hi hf hok hseq h
      exact ⟨x1, hx1, hr1, hbr⟩
  exact ⟨y, hy, hr', hcy, hrip, hbr⟩

/-! ### From the separation facts before the scopes

The steps above take `WrApart`/`FrameApart`/`MemDisjoint`/`Private`/`Globals` of the state after
the scopes. Here they come from facts before them: `FrameSep wl wh` over a frame window
(`ScopeMem`, kept by the scopes when they lie in the window), `MemRel` for `Globals`
(`globals_of_memRel`), and for `Private` the bytes private before and no `Escape` there
overlapping them (`afterScopes_private`). The `_sep` steps also give `FrameSep` after, when the
instruction's frame writes lie in the window (`WrIn`, a frame-offset fact of the decoded code). -/

/-- The frame bytes `opSem f vals` writes lie in the window `[lo, hi)`. -/
def WrIn (wl wh : Int) (f : Full.Opcode) (vals : Operands) : Prop :=
  ∀ r ∈ wranges f vals, wl ≤ r.1 ∧ r.1 + r.2 ≤ wh

theorem afterScopes_sep {wl wh : Int} {c : R.Code} {s : R.RState} {x : X86.State}
    (hr : RRel s x) (hs : FrameSep wl wh s.st x) (hw : Window wl wh s.fp)
    (hin : ScopesIn wl wh (c.scopesAt s.pc)) : AfterScopes c s (FrameSep wl wh · x) :=
  fun _ h1 => (sep_foldlM _ hin hw hr hs h1).2

theorem afterScopes_globals {ctx : Ctx} {c : R.Code} {s : R.RState} {x x0 : X86.State}
    {st0 : OpSem.State} (hg : Globals ctx c.ρ st0 x0) (hr : RRel s x) (hm : MemRel s.st x)
    (hsz : ∀ sc ∈ c.scopesAt s.pc, sc.size < 2 ^ 62) : AfterScopes c s (Globals ctx c.ρ · x) :=
  fun _ h1 => globals_of_memRel hg (memRel_foldlM _ hsz hr hm h1).2

theorem afterScopes_private {c : R.Code} {s : R.RState} {f : Full.Opcode} {vals : Operands}
    (hp : Private f vals s.st)
    (hesc : ∀ sc ∈ c.scopesAt s.pc, ∀ al, sc.kind = .escape al → ∀ r ∈ wranges f vals, ∀ o,
      inRange o r = true → ¬ (sc.frameOffset.toInt ≤ o ∧ o < sc.frameOffset.toInt + sc.size)) :
    AfterScopes c s (Private f vals) :=
  fun _ h1 => private_foldlM _ hesc hp h1

/-- Allocations keep their address, liveness and size. -/
def AllocShape (m m' : Memory) : Prop :=
  ∀ id a', m'.get? id = some a' → ∃ a, m.get? id = some a ∧ a'.addr = a.addr ∧
    a'.live = a.live ∧ a'.size = a.size

theorem allocShape_of_escOnly {st : OpSem.State} {m m' : Memory} (h : EscOnly st m m') :
    AllocShape m m' := fun id a' hg => by
  obtain ⟨a, ha, hae, hsz, -⟩ := h.2 id a' hg
  exact ⟨a, ha, by rw [hae], by rw [hae], hsz⟩

/-- `FrameSep` after a step that keeps the allocations' shape and the escaped objects, and changes
private frame bytes only inside the window. -/
theorem sep_of_shape {wl wh : Int} {st st' : OpSem.State} {x x' : X86.State}
    (hs : FrameSep wl wh st x) (hsh : AllocShape st.mem st'.mem) (he : st'.escaped = st.escaped)
    (hfr : ∀ o, (wl ≤ o ∧ o < wh) ∨ st'.frame o = st.frame o)
    (hb : x'.reg .rbp = x.reg .rbp) : FrameSep wl wh st' x' := by
  have hfp : ∀ o, fpAddr x' o = fpAddr x o := fun o => by simp [fpAddr, hb]
  have hea : ∀ o, st'.escapedAt o = st.escapedAt o := fun o => by
    unfold OpSem.State.escapedAt; rw [he]
  refine ⟨fun id a' o hg hl h1 h2 hin => ?_, fun o he' hu => ?_, ?_, ?_⟩
  · obtain ⟨a, ha, had, hlv, hsz⟩ := hsh id a' hg
    obtain ⟨e, hem, ho1, ho2, hid⟩ := hs.own id a o ha (hlv ▸ hl) h1 h2
      (by rw [← had, ← hsz, ← hfp]; exact hin)
    exact ⟨e, he ▸ hem, ho1, ho2, hid⟩
  · rcases hfr o with h | h
    · exact h
    · exact hs.init o (hea o ▸ he') (h ▸ hu)
  · intro id1 a1 id2 a2 i j hg1 hg2 hl1 hl2 hi hj heq
    obtain ⟨b1, hb1, had1, hlv1, hsz1⟩ := hsh id1 a1 hg1
    obtain ⟨b2, hb2, had2, hlv2, hsz2⟩ := hsh id2 a2 hg2
    rw [had1, had2] at heq
    exact hs.dis id1 b1 id2 b2 i j hb1 hb2 (hlv1 ▸ hl1) (hlv2 ▸ hl2) (hsz1 ▸ hi) (hsz2 ▸ hj) heq
  · intro id a' hg hl
    obtain ⟨a, ha, had, hlv, hsz⟩ := hsh id a' hg
    rw [had, hsz]; exact hs.space id a ha (hlv ▸ hl)

/-- `FrameSep` after an inline instruction's `opSem` (its output differs from the input in frame
bytes only, `SameButWrites`), when its writes lie in the window. -/
theorem sep_of_opSem {wl wh : Int} {f : Full.Opcode} {vals : Operands} {st st' : OpSem.State}
    {x x' : X86.State} {ch : OpSem.Choice} {ctl : Control} {fp : Footprint}
    (hs : FrameSep wl wh st x) (hsame : SameButWrites st' st) (hfp : footprint f = some fp)
    (hsem : opSem f vals st ch = .ok (ctl, st')) (hwin : WrIn wl wh f vals)
    (hb : x'.reg .rbp = x.reg .rbp) : FrameSep wl wh st' x' := by
  refine sep_of_shape hs (allocShape_of_escOnly hsame.2.1) hsame.1 (fun o => ?_) hb
  by_cases hin : ∃ r ∈ wranges f vals, inRange o r = true
  · obtain ⟨r, hr, ho⟩ := hin
    have := hwin r hr
    simp only [inRange, decide_eq_true_eq] at ho
    left; omega
  · right
    refine opSem_frame_writes hfp hsem o fun r hr => ?_
    have hw : wranges f vals = fp.writeRanges (opndVal f.info vals) := by
      unfold wranges; rw [hfp]
    cases h : inRange o r
    · rfl
    · exact absurd ⟨r, hw ▸ hr, h⟩ hin

theorem footprint_load {f : Full.Opcode} {w : W} (hs : shapeOk f (.load w) = true) :
    ∃ fp, footprint f = some fp := by
  obtain ⟨⟨r, hh⟩, -⟩ := shapeOk_spec hs
  simp only [classHandler] at hh
  rw [footprint_eq hh]
  exact ⟨_, (fp_load (ps := []) (tySize_of_parse (tyName_parse w).1)).1⟩

/-- The rip-relative classes' handlers have footprints. -/
theorem footprint_rip {f : Full.Opcode} {cls : Class} (hc : ripAddr cls = true)
    (hs : shapeOk f cls = true) : ∃ fp, footprint f = some fp := by
  obtain ⟨⟨r, hh⟩, -⟩ := shapeOk_spec hs
  rw [footprint_eq hh]
  cases cls <;> simp [ripAddr] at hc <;> simp only [classHandler]
  · exact ⟨_, fp_addr_const []⟩
  · obtain ⟨de, h⟩ := fp_addr_sym false; exact ⟨_, h⟩
  · obtain ⟨de, h⟩ := fp_addr_sym true; exact ⟨_, h⟩

/-- A store keeps the allocations' shape. -/
theorem store_shape {ρ : R.Addrs} {f : Full.Opcode} {w : W} {ops : List (R.Opnd Nat)}
    {vals : Operands} {st st' : OpSem.State} {ctl : Control} {ch : OpSem.Choice}
    (hs : shapeOk f (.store w) = true) (hv : nativeVals ρ f ops = some vals)
    (hsem : opSem f vals st ch = .ok (ctl, st')) : AllocShape st.mem st'.mem := by
  obtain ⟨⟨r, hh⟩, ho⟩ := shapeOk_spec hs
  simp only [classHandler, classOperands] at hh ho
  obtain ⟨o0, o1, v0, v1, rfl, rfl, h0, h1⟩ := nvs2 ho hv
  obtain ⟨pp, k, rfl, rfl⟩ := nv_mem.1 h0
  obtain ⟨s1, rfl, rfl⟩ := nv_slot.1 h1
  have hty := (tyName_parse w).1
  obtain ⟨bp, q, bs, mem', hrp, hq, hrs, hst, rfl, rfl⟩ := opSem_store hh hty ho hsem
  have hlen := readFrame_length hrs
  have hn0 : bs.length ≠ 0 := by rw [hlen]; cases w <;> decide
  obtain ⟨id, a, hg, -, -, -, rfl⟩ := store_ok hn0 hst
  intro id' a' h'
  simp only [get?_set hg] at h'
  split at h'
  · cases h'
    rename_i hid; subst hid
    exact ⟨a, hg, rfl, rfl, by simp [Allocation.size, storeData_size]⟩
  · exact ⟨a', h', rfl, rfl, rfl⟩

/-- `load_step` from the facts before the scopes, keeping `FrameSep` (see above). -/
theorem load_step_sep (ctx : Ctx) {wl wh : Int} {c : R.Code} {s s' : R.RState} {x : X86.State}
    {ch : OpSem.Choice} {op : Reduced.Opcode} {ops : List (R.Opnd Nat)} {f : Full.Opcode}
    {w : W} {items : List Item} {br : Option Cond} (hr : RRel s x) (hm : MemRel s.st x)
    (hs : FrameSep wl wh s.st x) (hw : Window wl wh s.fp) (hin : ScopesIn wl wh (c.scopesAt s.pc))
    (hsz : ∀ sc ∈ c.scopesAt s.pc, sc.size < 2 ^ 62)
    (hpriv : ∀ vals, nativeVals c.ρ f ops = some vals → AfterScopes c s (Private f vals))
    (hwin : ∀ vals, nativeVals c.ρ f ops = some vals → WrIn wl wh f vals)
    (hi : c.d.insns[s.pc]? = some (.native op ops)) (hf : op.full = some f)
    (hok : InlineOk f (.load w)) (hseq : sequence (.load w) ops = some (items, br))
    (h : R.step c s ch = .ok (.step s')) :
    ∃ x', execItems ctx items x = .ok x' ∧ RRel s' x' ∧ MemRel s'.st x' ∧ FrameSep wl wh s'.st x' ∧
      x'.rip = x.rip + BitVec.ofNat 64 (items.map Item.size).sum ∧
      BrOk f ops s s' br x' := by
  obtain ⟨fp, hfp⟩ := footprint_load hok.shape
  obtain ⟨x', hx, hr', ⟨hm', hs'⟩, hrip, hbr⟩ :=
    step_of (P := fun st y => MemRel st y ∧ FrameSep wl wh st y) (br := br) ctx hr hi hf hok h
      fun s1 vals st' ctl hsc hr1 hn ho => by
        have hm1 := (memRel_foldlM _ hsz hr hm hsc).2
        have hs1 := afterScopes_sep hr hs hw hin s1 hsc
        have hp1 := hpriv vals hn s1 hsc
        obtain ⟨x', hx, hpost, hm'⟩ := sound_load w ctx c.ρ f ops items br vals s1.st st' ctl ch x
          hok.shape hseq hn ho hr1.rel hp1 hm1 (hs1.wrApart hp1 (hwin vals hn))
        exact ⟨x', hx, hpost.rel, rbp_of_regs hpost.regs, escWF_of_sameButWrites hr1.wf hpost.same,
          ⟨hm', sep_of_opSem hs1 hpost.same hfp ho (hwin vals hn) (rbp_of_regs hpost.regs)⟩,
          hpost.rip, ctlOk_of_post hpost⟩
  exact ⟨x', hx, hr', hm', hs', hrip, hbr⟩

/-- `store_step` from the facts before the scopes, keeping `FrameSep` (see above). -/
theorem store_step_sep (ctx : Ctx) {wl wh : Int} {c : R.Code} {s s' : R.RState} {x : X86.State}
    {ch : OpSem.Choice} {op : Reduced.Opcode} {ops : List (R.Opnd Nat)} {f : Full.Opcode}
    {w : W} {items : List Item} {br : Option Cond} (hr : RRel s x) (hm : MemRel s.st x)
    (hs : FrameSep wl wh s.st x) (hw : Window wl wh s.fp) (hin : ScopesIn wl wh (c.scopesAt s.pc))
    (hsz : ∀ sc ∈ c.scopesAt s.pc, sc.size < 2 ^ 62)
    (hi : c.d.insns[s.pc]? = some (.native op ops)) (hf : op.full = some f)
    (hok : InlineOk f (.store w)) (hseq : sequence (.store w) ops = some (items, br))
    (h : R.step c s ch = .ok (.step s')) :
    ∃ x', execItems ctx items x = .ok x' ∧ RRel s' x' ∧ MemRel s'.st x' ∧ FrameSep wl wh s'.st x' ∧
      x'.rip = x.rip + BitVec.ofNat 64 (items.map Item.size).sum ∧
      BrOk f ops s s' br x' := by
  obtain ⟨x', hx, hr', ⟨hm', hs'⟩, hrip, hbr⟩ :=
    step_of (P := fun st y => MemRel st y ∧ FrameSep wl wh st y) (br := br) ctx hr hi hf hok h
      fun s1 vals st' ctl hsc hr1 hn ho => by
        have hm1 := (memRel_foldlM _ hsz hr hm hsc).2
        have hs1 := afterScopes_sep hr hs hw hin s1 hsc
        obtain ⟨rfl, x', hx, hpost⟩ := sound_store w ctx c.ρ f ops items br vals s1.st st' ctl ch x
          hok.shape hseq hn ho hr1.rel hm1 hs1.frameApart hs1.dis
        obtain ⟨hsize, hesc⟩ := store_allocs hok.shape hn ho
        have hwf : EscWF st' := ⟨fun e he => by rw [hesc] at he; rw [hsize]; exact hr1.wf.idLt e he,
          fun e he e' he' hid => by rw [hesc] at he he'; exact hr1.wf.idInj e he e' he' hid⟩
        have hb := rbp_of_regs hpost.regs
        exact ⟨x', hx, hpost.rel, hb, hwf,
          ⟨hpost.memRel, sep_of_shape hs1 (store_shape hok.shape hn ho) hesc
            (fun o => Or.inr (by rw [hpost.same.1])) hb⟩, hpost.rip, hpost.ctl⟩
  exact ⟨x', hx, hr', hm', hs', hrip, hbr⟩

/-- `rip_step` from the facts before the scopes, keeping `FrameSep` (see above): `Globals` from
`MemRel` and its layout part `hg`. -/
theorem rip_step_sep (ctx : Ctx) {wl wh : Int} {c : R.Code} {s s' : R.RState} {x x0 : X86.State}
    {st0 : OpSem.State} {ch : OpSem.Choice} {op : Reduced.Opcode} {ops : List (R.Opnd Nat)}
    {f : Full.Opcode} {cls : Class} {items : List Item} {br : Option Cond}
    (hc : ripAddr cls = true) (hr : RRel s x) (hm : MemRel s.st x) (hg : Globals ctx c.ρ st0 x0)
    (hs : FrameSep wl wh s.st x) (hw : Window wl wh s.fp) (hin : ScopesIn wl wh (c.scopesAt s.pc))
    (hsz : ∀ sc ∈ c.scopesAt s.pc, sc.size < 2 ^ 62)
    (hwin : ∀ vals, nativeVals c.ρ f ops = some vals → WrIn wl wh f vals)
    (hi : c.d.insns[s.pc]? = some (.native op ops)) (hf : op.full = some f)
    (hok : InlineOk f cls) (hseq : sequence cls ops = some (items, br))
    (h : R.step c s ch = .ok (.step s')) :
    ∃ x', execItems ctx items x = .ok x' ∧ RRel s' x' ∧ FrameSep wl wh s'.st x' ∧
      x'.rip = x.rip + BitVec.ofNat 64 (items.map Item.size).sum ∧
      BrOk f ops s s' br x' := by
  obtain ⟨fp, hfp⟩ := footprint_rip hc hok.shape
  have hgs := afterScopes_globals hg hr hm hsz
  obtain ⟨x', hx, hr', hs', hrip, hbr⟩ :=
    step_of (P := fun st y => FrameSep wl wh st y) (br := br) ctx hr hi hf hok h
    fun s1 vals st' ctl hsc hr1 hn ho => by
      have hs1 := afterScopes_sep hr hs hw hin s1 hsc
      obtain ⟨x', hx, hpost⟩ := inline_sound_rip cls hc ctx c.ρ f ops items br vals s1.st st' ctl
        ch x hok.shape hseq hn ho hr1.rel (hgs s1 hsc)
      exact ⟨x', hx, hpost.rel, rbp_of_regs hpost.regs,
        escWF_of_sameButWrites hr1.wf hpost.same,
        sep_of_opSem hs1 hpost.same hfp ho (hwin vals hn) (rbp_of_regs hpost.regs), hpost.rip,
        ctlOk_of_post hpost⟩
  exact ⟨x', hx, hr', hs', hrip, hbr⟩

/-- `load_step_sep` through the register cache. -/
theorem load_step_sep_cached (ctx : Ctx) {wl wh : Int} {c : R.Code} {s s' : R.RState}
    {x : X86.State} {ch : OpSem.Choice} {op : Reduced.Opcode} {ops : List (R.Opnd Nat)}
    {f : Full.Opcode} {w : W} {cand : List Item} {br : Option Cond} {cache : Cache}
    (hinv : CacheInv cache x) (hr : RRel s x) (hm : MemRel s.st x)
    (hs : FrameSep wl wh s.st x) (hw : Window wl wh s.fp) (hin : ScopesIn wl wh (c.scopesAt s.pc))
    (hsz : ∀ sc ∈ c.scopesAt s.pc, sc.size < 2 ^ 62)
    (hpriv : ∀ vals, nativeVals c.ρ f ops = some vals → AfterScopes c s (Private f vals))
    (hwin : ∀ vals, nativeVals c.ρ f ops = some vals → WrIn wl wh f vals)
    (hi : c.d.insns[s.pc]? = some (.native op ops)) (hf : op.full = some f)
    (hok : InlineOk f (.load w)) (hseq : sequence (.load w) ops = some (cand, br))
    (h : R.step c s ch = .ok (.step s')) :
    ∃ x', execItems ctx (cache.emit cand).1 x = .ok x' ∧ RRel s' x' ∧ MemRel s'.st x' ∧
      FrameSep wl wh s'.st x' ∧ CacheInv (cache.emit cand).2 x' ∧
      x'.rip = x.rip + BitVec.ofNat 64 ((cache.emit cand).1.map Item.size).sum ∧
      BrOk f ops s s' br x' := by
  obtain ⟨y, hy, ⟨hr', hm', hs', hbr⟩, hcy, hrip⟩ := cached_of ctx
    (Q := fun y => RRel s' y ∧ MemRel s'.st y ∧ FrameSep wl wh s'.st y ∧ BrOk f ops s s' br y) hinv
    (fun _ h => by cases h) hseq
    (fun y z hb hm hf hq =>
      ⟨rrel_congr hq.1 hb hm, memRel_congr hm hq.2.1, hq.2.2.1.congr hb, brOk_congr hf hq.2.2.2⟩)
    fun xr hb => by
      obtain ⟨x1, hx1, hr1, hm1, hs1, -, hbr⟩ := load_step_sep ctx (x := swapS xr x)
        (rrel_congr hr (swapS_rbp hb x) rfl) (memRel_congr rfl hm) (hs.congr (swapS_rbp hb x))
        hw hin hsz hpriv hwin hi hf hok hseq h
      exact ⟨x1, hx1, hr1, hm1, hs1, hbr⟩
  exact ⟨y, hy, hr', hm', hs', hcy, hrip, hbr⟩

/-- `store_step_sep` through the register cache. -/
theorem store_step_sep_cached (ctx : Ctx) {wl wh : Int} {c : R.Code} {s s' : R.RState}
    {x : X86.State} {ch : OpSem.Choice} {op : Reduced.Opcode} {ops : List (R.Opnd Nat)}
    {f : Full.Opcode} {w : W} {cand : List Item} {br : Option Cond} {cache : Cache}
    (hinv : CacheInv cache x) (hr : RRel s x) (hm : MemRel s.st x)
    (hs : FrameSep wl wh s.st x) (hw : Window wl wh s.fp) (hin : ScopesIn wl wh (c.scopesAt s.pc))
    (hsz : ∀ sc ∈ c.scopesAt s.pc, sc.size < 2 ^ 62)
    (hi : c.d.insns[s.pc]? = some (.native op ops)) (hf : op.full = some f)
    (hok : InlineOk f (.store w)) (hseq : sequence (.store w) ops = some (cand, br))
    (h : R.step c s ch = .ok (.step s')) :
    ∃ x', execItems ctx (cache.emit cand).1 x = .ok x' ∧ RRel s' x' ∧ MemRel s'.st x' ∧
      FrameSep wl wh s'.st x' ∧ CacheInv (cache.emit cand).2 x' ∧
      x'.rip = x.rip + BitVec.ofNat 64 ((cache.emit cand).1.map Item.size).sum ∧
      BrOk f ops s s' br x' := by
  obtain ⟨y, hy, ⟨hr', hm', hs', hbr⟩, hcy, hrip⟩ := cached_of ctx
    (Q := fun y => RRel s' y ∧ MemRel s'.st y ∧ FrameSep wl wh s'.st y ∧ BrOk f ops s s' br y) hinv
    (fun _ h => by cases h) hseq
    (fun y z hb hm hf hq =>
      ⟨rrel_congr hq.1 hb hm, memRel_congr hm hq.2.1, hq.2.2.1.congr hb, brOk_congr hf hq.2.2.2⟩)
    fun xr hb => by
      obtain ⟨x1, hx1, hr1, hm1, hs1, -, hbr⟩ := store_step_sep ctx (x := swapS xr x)
        (rrel_congr hr (swapS_rbp hb x) rfl) (memRel_congr rfl hm) (hs.congr (swapS_rbp hb x))
        hw hin hsz hi hf hok hseq h
      exact ⟨x1, hx1, hr1, hm1, hs1, hbr⟩
  exact ⟨y, hy, hr', hm', hs', hcy, hrip, hbr⟩

/-- `rip_step_sep` through the register cache. -/
theorem rip_step_sep_cached (ctx : Ctx) {wl wh : Int} {c : R.Code} {s s' : R.RState}
    {x x0 : X86.State} {st0 : OpSem.State} {ch : OpSem.Choice} {op : Reduced.Opcode}
    {ops : List (R.Opnd Nat)} {f : Full.Opcode} {cls : Class} {cand : List Item}
    {br : Option Cond} {cache : Cache} (hc : ripAddr cls = true) (hinv : CacheInv cache x)
    (hr : RRel s x) (hm : MemRel s.st x) (hg : Globals ctx c.ρ st0 x0)
    (hs : FrameSep wl wh s.st x) (hw : Window wl wh s.fp) (hin : ScopesIn wl wh (c.scopesAt s.pc))
    (hsz : ∀ sc ∈ c.scopesAt s.pc, sc.size < 2 ^ 62)
    (hwin : ∀ vals, nativeVals c.ρ f ops = some vals → WrIn wl wh f vals)
    (hi : c.d.insns[s.pc]? = some (.native op ops)) (hf : op.full = some f)
    (hok : InlineOk f cls) (hseq : sequence cls ops = some (cand, br))
    (h : R.step c s ch = .ok (.step s')) :
    ∃ x', execItems ctx (cache.emit cand).1 x = .ok x' ∧ RRel s' x' ∧ FrameSep wl wh s'.st x' ∧
      CacheInv (cache.emit cand).2 x' ∧
      x'.rip = x.rip + BitVec.ofNat 64 ((cache.emit cand).1.map Item.size).sum ∧
      BrOk f ops s s' br x' := by
  have hext : ∀ b, cls ≠ .ext .q b true := fun b he => by subst he; simp [ripAddr] at hc
  obtain ⟨y, hy, ⟨hr', hs', hbr⟩, hcy, hrip⟩ := cached_of ctx
    (Q := fun y => RRel s' y ∧ FrameSep wl wh s'.st y ∧ BrOk f ops s s' br y) hinv hext hseq
    (fun y z hb hm hf hq => ⟨rrel_congr hq.1 hb hm, hq.2.1.congr hb, brOk_congr hf hq.2.2⟩)
    fun xr hb => by
      obtain ⟨x1, hx1, hr1, hs1, -, hbr⟩ := rip_step_sep ctx (x := swapS xr x) hc
        (rrel_congr hr (swapS_rbp hb x) rfl) (memRel_congr rfl hm) hg
        (hs.congr (swapS_rbp hb x)) hw hin hsz hwin hi hf hok hseq h
      exact ⟨x1, hx1, hr1, hs1, hbr⟩
  exact ⟨y, hy, hr', hs', hcy, hrip, hbr⟩

/-! ### Keeping the registers and the memory outside the writes -/

/-- The registers but `rax` and `rcx` kept. -/
def KeptRegs (x x' : X86.State) : Prop := ∀ i : Fin 16, i ≠ 0 → i ≠ 1 → x'.regs i = x.regs i

/-- Memory kept outside the frame ranges the instruction writes (`Post.memOut`). -/
def MemOutW (c : R.Code) (f : Full.Opcode) (ops : List (R.Opnd Nat)) (x y : X86.State) : Prop :=
  ∀ vals, nativeVals c.ρ f ops = some vals → ∀ a,
    (∀ r ∈ wranges f vals, r.2 ≤ (a - fpAddr x r.1).toNat) → y.mem a = x.mem a

/-- Memory kept outside the live allocations after the scopes (`PostMem.memOut`). -/
def MemOutA (c : R.Code) (s : R.RState) (x y : X86.State) : Prop :=
  AfterScopes c s fun st => ∀ b, (∀ id a, st.mem.get? id = some a → a.live = true →
    ¬ (b - BitVec.ofNat 64 a.addr).toNat < a.size) → y.mem b = x.mem b

theorem memOutW_of {c : R.Code} {f : Full.Opcode} {ops : List (R.Opnd Nat)} {vals : Operands}
    {x y : X86.State} (hn : nativeVals c.ρ f ops = some vals)
    (h : ∀ a, (∀ r ∈ wranges f vals, r.2 ≤ (a - fpAddr x r.1).toNat) → y.mem a = x.mem a) :
    MemOutW c f ops x y := by
  intro vals' hv'
  have e : vals' = vals := Option.some.inj (hv'.symm.trans hn)
  subst e
  exact h

theorem memOutA_of {c : R.Code} {s s1 : R.RState} {x y : X86.State}
    (hsc : (c.scopesAt s.pc).foldlM R.applyScope s = .ok s1)
    (h : ∀ b, (∀ id a, s1.st.mem.get? id = some a → a.live = true →
      ¬ (b - BitVec.ofNat 64 a.addr).toNat < a.size) → y.mem b = x.mem b) :
    MemOutA c s x y := by
  intro s2 hs2
  have e : s2 = s1 := by
    have h2 := hs2.symm.trans hsc
    cases h2
    rfl
  subst e
  exact h

theorem fpAddr_swapS {xr : Reg} (hb : xr ≠ .rbp) (x : X86.State) (o : Int) :
    fpAddr (swapS xr x) o = fpAddr x o := by
  simp only [fpAddr, swapS_rbp hb x]

theorem memOutW_swap {c : R.Code} {f : Full.Opcode} {ops : List (R.Opnd Nat)} {xr : Reg}
    {x x1 : X86.State} (hb : xr ≠ .rbp) (h : MemOutW c f ops (swapS xr x) x1) :
    MemOutW c f ops x x1 := by
  intro vals hv a ha
  have e := h vals hv a (fun r hr => by rw [fpAddr_swapS hb]; exact ha r hr)
  rw [e]
  rfl

theorem memOutA_swap {c : R.Code} {s : R.RState} {xr : Reg} {x x1 : X86.State}
    (h : MemOutA c s (swapS xr x) x1) : MemOutA c s x x1 :=
  fun s1 hs b hb => h s1 hs b hb

theorem memOutW_congr {c : R.Code} {f : Full.Opcode} {ops : List (R.Opnd Nat)} {x y z : X86.State}
    (hm : y.mem = z.mem) (h : MemOutW c f ops x z) : MemOutW c f ops x y :=
  fun vals hv a ha => by rw [hm]; exact h vals hv a ha

theorem memOutA_congr {c : R.Code} {s : R.RState} {x y z : X86.State}
    (hm : y.mem = z.mem) (h : MemOutA c s x z) : MemOutA c s x y :=
  fun s1 hs b hb => by rw [hm]; exact h s1 hs b hb

/-- `load_step_sep`, also keeping the registers but `rax` and `rcx`, and memory outside the
written frame ranges. -/
theorem load_step_sep_regs (ctx : Ctx) {wl wh : Int} {c : R.Code} {s s' : R.RState}
    {x : X86.State} {ch : OpSem.Choice} {op : Reduced.Opcode} {ops : List (R.Opnd Nat)}
    {f : Full.Opcode} {w : W} {items : List Item} {br : Option Cond} (hr : RRel s x)
    (hm : MemRel s.st x)
    (hs : FrameSep wl wh s.st x) (hw : Window wl wh s.fp) (hin : ScopesIn wl wh (c.scopesAt s.pc))
    (hsz : ∀ sc ∈ c.scopesAt s.pc, sc.size < 2 ^ 62)
    (hpriv : ∀ vals, nativeVals c.ρ f ops = some vals → AfterScopes c s (Private f vals))
    (hwin : ∀ vals, nativeVals c.ρ f ops = some vals → WrIn wl wh f vals)
    (hi : c.d.insns[s.pc]? = some (.native op ops)) (hf : op.full = some f)
    (hok : InlineOk f (.load w)) (hseq : sequence (.load w) ops = some (items, br))
    (h : R.step c s ch = .ok (.step s')) :
    ∃ x', execItems ctx items x = .ok x' ∧ RRel s' x' ∧ MemRel s'.st x' ∧ FrameSep wl wh s'.st x' ∧
      KeptRegs x x' ∧ MemOutW c f ops x x' ∧
      x'.rip = x.rip + BitVec.ofNat 64 (items.map Item.size).sum ∧
      BrOk f ops s s' br x' := by
  obtain ⟨fp, hfp⟩ := footprint_load hok.shape
  obtain ⟨x', hx, hr', ⟨hm', hs', hk', ho'⟩, hrip, hbr⟩ :=
    step_of (P := fun st y => MemRel st y ∧ FrameSep wl wh st y ∧ KeptRegs x y ∧
      MemOutW c f ops x y) (br := br) ctx hr hi hf hok h
      fun s1 vals st' ctl hsc hr1 hn ho => by
        have hm1 := (memRel_foldlM _ hsz hr hm hsc).2
        have hs1 := afterScopes_sep hr hs hw hin s1 hsc
        have hp1 := hpriv vals hn s1 hsc
        obtain ⟨x', hx, hpost, hm'⟩ := sound_load w ctx c.ρ f ops items br vals s1.st st' ctl ch x
          hok.shape hseq hn ho hr1.rel hp1 hm1 (hs1.wrApart hp1 (hwin vals hn))
        exact ⟨x', hx, hpost.rel, rbp_of_regs hpost.regs, escWF_of_sameButWrites hr1.wf hpost.same,
          ⟨hm', sep_of_opSem hs1 hpost.same hfp ho (hwin vals hn) (rbp_of_regs hpost.regs),
            hpost.regs, memOutW_of hn hpost.memOut⟩,
          hpost.rip, ctlOk_of_post hpost⟩
  exact ⟨x', hx, hr', hm', hs', hk', ho', hrip, hbr⟩

/-- `store_step_sep`, also keeping the registers but `rax` and `rcx`, and memory outside the
live allocations after the scopes. -/
theorem store_step_sep_regs (ctx : Ctx) {wl wh : Int} {c : R.Code} {s s' : R.RState}
    {x : X86.State} {ch : OpSem.Choice} {op : Reduced.Opcode} {ops : List (R.Opnd Nat)}
    {f : Full.Opcode} {w : W} {items : List Item} {br : Option Cond} (hr : RRel s x)
    (hm : MemRel s.st x)
    (hs : FrameSep wl wh s.st x) (hw : Window wl wh s.fp) (hin : ScopesIn wl wh (c.scopesAt s.pc))
    (hsz : ∀ sc ∈ c.scopesAt s.pc, sc.size < 2 ^ 62)
    (hi : c.d.insns[s.pc]? = some (.native op ops)) (hf : op.full = some f)
    (hok : InlineOk f (.store w)) (hseq : sequence (.store w) ops = some (items, br))
    (h : R.step c s ch = .ok (.step s')) :
    ∃ x', execItems ctx items x = .ok x' ∧ RRel s' x' ∧ MemRel s'.st x' ∧ FrameSep wl wh s'.st x' ∧
      KeptRegs x x' ∧ MemOutA c s x x' ∧
      x'.rip = x.rip + BitVec.ofNat 64 (items.map Item.size).sum ∧
      BrOk f ops s s' br x' := by
  obtain ⟨x', hx, hr', ⟨hm', hs', hk', ho'⟩, hrip, hbr⟩ :=
    step_of (P := fun st y => MemRel st y ∧ FrameSep wl wh st y ∧ KeptRegs x y ∧
      MemOutA c s x y) (br := br) ctx hr hi hf hok h
      fun s1 vals st' ctl hsc hr1 hn ho => by
        have hm1 := (memRel_foldlM _ hsz hr hm hsc).2
        have hs1 := afterScopes_sep hr hs hw hin s1 hsc
        obtain ⟨rfl, x', hx, hpost⟩ := sound_store w ctx c.ρ f ops items br vals s1.st st' ctl ch x
          hok.shape hseq hn ho hr1.rel hm1 hs1.frameApart hs1.dis
        obtain ⟨hsize, hesc⟩ := store_allocs hok.shape hn ho
        have hwf : EscWF st' := ⟨fun e he => by rw [hesc] at he; rw [hsize]; exact hr1.wf.idLt e he,
          fun e he e' he' hid => by rw [hesc] at he he'; exact hr1.wf.idInj e he e' he' hid⟩
        have hb := rbp_of_regs hpost.regs
        exact ⟨x', hx, hpost.rel, hb, hwf,
          ⟨hpost.memRel, sep_of_shape hs1 (store_shape hok.shape hn ho) hesc
            (fun o => Or.inr (by rw [hpost.same.1])) hb, hpost.regs,
            memOutA_of hsc hpost.memOut⟩, hpost.rip, hpost.ctl⟩
  exact ⟨x', hx, hr', hm', hs', hk', ho', hrip, hbr⟩

/-- `rip_step_sep`, also keeping the registers but `rax` and `rcx`, and memory outside the
written frame ranges. -/
theorem rip_step_sep_regs (ctx : Ctx) {wl wh : Int} {c : R.Code} {s s' : R.RState}
    {x x0 : X86.State} {st0 : OpSem.State} {ch : OpSem.Choice} {op : Reduced.Opcode}
    {ops : List (R.Opnd Nat)} {f : Full.Opcode} {cls : Class} {items : List Item}
    {br : Option Cond}
    (hc : ripAddr cls = true) (hr : RRel s x) (hm : MemRel s.st x) (hg : Globals ctx c.ρ st0 x0)
    (hs : FrameSep wl wh s.st x) (hw : Window wl wh s.fp) (hin : ScopesIn wl wh (c.scopesAt s.pc))
    (hsz : ∀ sc ∈ c.scopesAt s.pc, sc.size < 2 ^ 62)
    (hwin : ∀ vals, nativeVals c.ρ f ops = some vals → WrIn wl wh f vals)
    (hi : c.d.insns[s.pc]? = some (.native op ops)) (hf : op.full = some f)
    (hok : InlineOk f cls) (hseq : sequence cls ops = some (items, br))
    (h : R.step c s ch = .ok (.step s')) :
    ∃ x', execItems ctx items x = .ok x' ∧ RRel s' x' ∧ FrameSep wl wh s'.st x' ∧
      KeptRegs x x' ∧ MemOutW c f ops x x' ∧
      x'.rip = x.rip + BitVec.ofNat 64 (items.map Item.size).sum ∧
      BrOk f ops s s' br x' := by
  obtain ⟨fp, hfp⟩ := footprint_rip hc hok.shape
  have hgs := afterScopes_globals hg hr hm hsz
  obtain ⟨x', hx, hr', ⟨hs', hk', ho'⟩, hrip, hbr⟩ :=
    step_of (P := fun st y => FrameSep wl wh st y ∧ KeptRegs x y ∧ MemOutW c f ops x y)
      (br := br) ctx hr hi hf hok h
    fun s1 vals st' ctl hsc hr1 hn ho => by
      have hs1 := afterScopes_sep hr hs hw hin s1 hsc
      obtain ⟨x', hx, hpost⟩ := inline_sound_rip cls hc ctx c.ρ f ops items br vals s1.st st' ctl
        ch x hok.shape hseq hn ho hr1.rel (hgs s1 hsc)
      exact ⟨x', hx, hpost.rel, rbp_of_regs hpost.regs,
        escWF_of_sameButWrites hr1.wf hpost.same,
        ⟨sep_of_opSem hs1 hpost.same hfp ho (hwin vals hn) (rbp_of_regs hpost.regs), hpost.regs,
          memOutW_of hn hpost.memOut⟩,
        hpost.rip, ctlOk_of_post hpost⟩
  exact ⟨x', hx, hr', hs', hk', ho', hrip, hbr⟩

/-- The registers an emitted run keeps: all but `rax`, `rcx` (or `clobbers`) and the register
`emit` computes in. -/
def EmitKept (Clob : Fin 16 → Prop) (cache : Cache) (cand : List Item) (x y : X86.State) : Prop :=
  ∀ i, ¬ Clob i → i ≠ (pool[(emitHead { cache with tick := cache.tick + 1 } cand).1]!).idx →
    y.regs i = x.regs i

theorem keptRegs_swap {xr : Reg} {x x1 : X86.State} (h : KeptRegs (swapS xr x) x1) :
    ∀ i, ¬ (i = 0 ∨ i = 1) → x1.regs i = (swapS xr x).regs i :=
  fun i hi => h i (fun e => hi (.inl e)) (fun e => hi (.inr e))

/-- `load_step_sep_cached`, also keeping the registers (`EmitKept`) and memory outside the
written frame ranges. -/
theorem load_step_sep_cached_regs (ctx : Ctx) {wl wh : Int} {c : R.Code} {s s' : R.RState}
    {x : X86.State} {ch : OpSem.Choice} {op : Reduced.Opcode} {ops : List (R.Opnd Nat)}
    {f : Full.Opcode} {w : W} {cand : List Item} {br : Option Cond} {cache : Cache}
    (hinv : CacheInv cache x) (hr : RRel s x) (hm : MemRel s.st x)
    (hs : FrameSep wl wh s.st x) (hw : Window wl wh s.fp) (hin : ScopesIn wl wh (c.scopesAt s.pc))
    (hsz : ∀ sc ∈ c.scopesAt s.pc, sc.size < 2 ^ 62)
    (hpriv : ∀ vals, nativeVals c.ρ f ops = some vals → AfterScopes c s (Private f vals))
    (hwin : ∀ vals, nativeVals c.ρ f ops = some vals → WrIn wl wh f vals)
    (hi : c.d.insns[s.pc]? = some (.native op ops)) (hf : op.full = some f)
    (hok : InlineOk f (.load w)) (hseq : sequence (.load w) ops = some (cand, br))
    (h : R.step c s ch = .ok (.step s')) :
    ∃ x', execItems ctx (cache.emit cand).1 x = .ok x' ∧ RRel s' x' ∧ MemRel s'.st x' ∧
      FrameSep wl wh s'.st x' ∧ CacheInv (cache.emit cand).2 x' ∧
      x'.rip = x.rip + BitVec.ofNat 64 ((cache.emit cand).1.map Item.size).sum ∧
      BrOk f ops s s' br x' ∧ EmitKept (fun i => i = 0 ∨ i = 1) cache cand x x' ∧
      MemOutW c f ops x x' := by
  obtain ⟨y, hy, ⟨hr', hm', hs', hbr, ho'⟩, hcy, hrip, hk⟩ := cached_of_regs ctx
    (Q := fun y => RRel s' y ∧ MemRel s'.st y ∧ FrameSep wl wh s'.st y ∧ BrOk f ops s s' br y ∧
      MemOutW c f ops x y)
    (Clob := fun i => i = 0 ∨ i = 1) (.inl rfl) hinv
    (fun _ h => by cases h) hseq
    (fun y z hb hm hf hq =>
      ⟨rrel_congr hq.1 hb hm, memRel_congr hm hq.2.1, hq.2.2.1.congr hb,
        brOk_congr hf hq.2.2.2.1, memOutW_congr hm hq.2.2.2.2⟩)
    fun xr hb => by
      obtain ⟨x1, hx1, hr1, hm1, hs1, hk1, ho1, -, hbr⟩ := load_step_sep_regs ctx
        (x := swapS xr x)
        (rrel_congr hr (swapS_rbp hb x) rfl) (memRel_congr rfl hm) (hs.congr (swapS_rbp hb x))
        hw hin hsz hpriv hwin hi hf hok hseq h
      exact ⟨x1, hx1, ⟨hr1, hm1, hs1, hbr, memOutW_swap hb ho1⟩, keptRegs_swap hk1⟩
  exact ⟨y, hy, hr', hm', hs', hcy, hrip, hbr, hk, ho'⟩

/-- `store_step_sep_cached`, also keeping the registers (`EmitKept`) and memory outside the
live allocations after the scopes. -/
theorem store_step_sep_cached_regs (ctx : Ctx) {wl wh : Int} {c : R.Code} {s s' : R.RState}
    {x : X86.State} {ch : OpSem.Choice} {op : Reduced.Opcode} {ops : List (R.Opnd Nat)}
    {f : Full.Opcode} {w : W} {cand : List Item} {br : Option Cond} {cache : Cache}
    (hinv : CacheInv cache x) (hr : RRel s x) (hm : MemRel s.st x)
    (hs : FrameSep wl wh s.st x) (hw : Window wl wh s.fp) (hin : ScopesIn wl wh (c.scopesAt s.pc))
    (hsz : ∀ sc ∈ c.scopesAt s.pc, sc.size < 2 ^ 62)
    (hi : c.d.insns[s.pc]? = some (.native op ops)) (hf : op.full = some f)
    (hok : InlineOk f (.store w)) (hseq : sequence (.store w) ops = some (cand, br))
    (h : R.step c s ch = .ok (.step s')) :
    ∃ x', execItems ctx (cache.emit cand).1 x = .ok x' ∧ RRel s' x' ∧ MemRel s'.st x' ∧
      FrameSep wl wh s'.st x' ∧ CacheInv (cache.emit cand).2 x' ∧
      x'.rip = x.rip + BitVec.ofNat 64 ((cache.emit cand).1.map Item.size).sum ∧
      BrOk f ops s s' br x' ∧ EmitKept (fun i => i = 0 ∨ i = 1) cache cand x x' ∧
      MemOutA c s x x' := by
  obtain ⟨y, hy, ⟨hr', hm', hs', hbr, ho'⟩, hcy, hrip, hk⟩ := cached_of_regs ctx
    (Q := fun y => RRel s' y ∧ MemRel s'.st y ∧ FrameSep wl wh s'.st y ∧ BrOk f ops s s' br y ∧
      MemOutA c s x y)
    (Clob := fun i => i = 0 ∨ i = 1) (.inl rfl) hinv
    (fun _ h => by cases h) hseq
    (fun y z hb hm hf hq =>
      ⟨rrel_congr hq.1 hb hm, memRel_congr hm hq.2.1, hq.2.2.1.congr hb,
        brOk_congr hf hq.2.2.2.1, memOutA_congr hm hq.2.2.2.2⟩)
    fun xr hb => by
      obtain ⟨x1, hx1, hr1, hm1, hs1, hk1, ho1, -, hbr⟩ := store_step_sep_regs ctx
        (x := swapS xr x)
        (rrel_congr hr (swapS_rbp hb x) rfl) (memRel_congr rfl hm) (hs.congr (swapS_rbp hb x))
        hw hin hsz hi hf hok hseq h
      exact ⟨x1, hx1, ⟨hr1, hm1, hs1, hbr, memOutA_swap ho1⟩, keptRegs_swap hk1⟩
  exact ⟨y, hy, hr', hm', hs', hcy, hrip, hbr, hk, ho'⟩

/-- `rip_step_sep_cached`, also keeping the registers (`EmitKept`) and memory outside the
written frame ranges. -/
theorem rip_step_sep_cached_regs (ctx : Ctx) {wl wh : Int} {c : R.Code} {s s' : R.RState}
    {x x0 : X86.State} {st0 : OpSem.State} {ch : OpSem.Choice} {op : Reduced.Opcode}
    {ops : List (R.Opnd Nat)} {f : Full.Opcode} {cls : Class} {cand : List Item}
    {br : Option Cond} {cache : Cache} (hc : ripAddr cls = true) (hinv : CacheInv cache x)
    (hr : RRel s x) (hm : MemRel s.st x) (hg : Globals ctx c.ρ st0 x0)
    (hs : FrameSep wl wh s.st x) (hw : Window wl wh s.fp) (hin : ScopesIn wl wh (c.scopesAt s.pc))
    (hsz : ∀ sc ∈ c.scopesAt s.pc, sc.size < 2 ^ 62)
    (hwin : ∀ vals, nativeVals c.ρ f ops = some vals → WrIn wl wh f vals)
    (hi : c.d.insns[s.pc]? = some (.native op ops)) (hf : op.full = some f)
    (hok : InlineOk f cls) (hseq : sequence cls ops = some (cand, br))
    (h : R.step c s ch = .ok (.step s')) :
    ∃ x', execItems ctx (cache.emit cand).1 x = .ok x' ∧ RRel s' x' ∧ FrameSep wl wh s'.st x' ∧
      CacheInv (cache.emit cand).2 x' ∧
      x'.rip = x.rip + BitVec.ofNat 64 ((cache.emit cand).1.map Item.size).sum ∧
      BrOk f ops s s' br x' ∧ EmitKept (fun i => i = 0 ∨ i = 1) cache cand x x' ∧
      MemOutW c f ops x x' := by
  have hext : ∀ b, cls ≠ .ext .q b true := fun b he => by subst he; simp [ripAddr] at hc
  obtain ⟨y, hy, ⟨hr', hs', hbr, ho'⟩, hcy, hrip, hk⟩ := cached_of_regs ctx
    (Q := fun y => RRel s' y ∧ FrameSep wl wh s'.st y ∧ BrOk f ops s s' br y ∧
      MemOutW c f ops x y)
    (Clob := fun i => i = 0 ∨ i = 1) (.inl rfl) hinv hext hseq
    (fun y z hb hm hf hq => ⟨rrel_congr hq.1 hb hm, hq.2.1.congr hb, brOk_congr hf hq.2.2.1,
      memOutW_congr hm hq.2.2.2⟩)
    fun xr hb => by
      obtain ⟨x1, hx1, hr1, hs1, hk1, ho1, -, hbr⟩ := rip_step_sep_regs ctx (x := swapS xr x) hc
        (rrel_congr hr (swapS_rbp hb x) rfl) (memRel_congr rfl hm) hg
        (hs.congr (swapS_rbp hb x)) hw hin hsz hwin hi hf hok hseq h
      exact ⟨x1, hx1, ⟨hr1, hs1, hbr, memOutW_swap hb ho1⟩, keptRegs_swap hk1⟩
  exact ⟨y, hy, hr', hs', hcy, hrip, hbr, hk, ho'⟩

/-- `inline_step_cached`, also keeping the registers outside `clobbers cls` (`EmitKept`) and
memory outside the written frame ranges (`inline_stepC_mem`). -/
theorem inline_step_cached_regs (ctx : Ctx) {c : R.Code} {s s' : R.RState} {x : X86.State}
    {ch : OpSem.Choice} {op : Reduced.Opcode} {ops : List (R.Opnd Nat)} {f : Full.Opcode}
    {cls : Class} {cand : List Item} {br : Option Cond} {cache : Cache} (hsound : SoundC cls)
    (hinv : CacheInv cache x) (hr : RRel s x) (hi : c.d.insns[s.pc]? = some (.native op ops))
    (hf : op.full = some f) (hok : InlineOk f cls) (hext : ∀ b, cls ≠ .ext .q b true)
    (hseq : sequence cls ops = some (cand, br)) (h : R.step c s ch = .ok (.step s')) :
    ∃ x', execItems ctx (cache.emit cand).1 x = .ok x' ∧ RRel s' x' ∧
      CacheInv (cache.emit cand).2 x' ∧
      x'.rip = x.rip + BitVec.ofNat 64 ((cache.emit cand).1.map Item.size).sum ∧
      BrOk f ops s s' br x' ∧ EmitKept (· ∈ clobbers cls) cache cand x x' ∧
      MemOutW c f ops x x' := by
  obtain ⟨y, hy, ⟨hr', hbr, ho'⟩, hcy, hrip, hk⟩ := cached_of_regs ctx
    (Q := fun y => RRel s' y ∧ BrOk f ops s s' br y ∧ MemOutW c f ops x y)
    (Clob := (· ∈ clobbers cls)) (clobbers_01 cls).1 hinv hext hseq
    (fun y z hb hm hf hq => ⟨rrel_congr hq.1 hb hm, brOk_congr hf hq.2.1,
      memOutW_congr hm hq.2.2⟩)
    fun xr hb => by
      obtain ⟨x1, hx1, hr1, -, hk1, hbr, ho1⟩ := inline_stepC_mem ctx (x := swapS xr x) hsound
        (rrel_congr hr (swapS_rbp hb x) rfl) hi hf hok hseq h
      exact ⟨x1, hx1, ⟨hr1, by cases br <;> exact hbr, memOutW_swap hb ho1⟩, hk1⟩
  exact ⟨y, hy, hr', hcy, hrip, hbr, hk, ho'⟩

end Ryo.Proofs.CacheMem
