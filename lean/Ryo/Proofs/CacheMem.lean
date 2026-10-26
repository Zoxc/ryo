/-
Ryo.Proofs.CacheMem — one R step of a `load`, `store` or rip-relative address instruction
(`addrConst`, `addrSym`, `addrSymInd`) against its sequence, on `rax` and as the register
cache emits it (aot.md §C2 "Inline sequences", "Register cache"): the classes
`inline_step_cached` (`Ryo/Proofs/CacheStep.lean`) leaves out, as they have `Sound` only with
more hypotheses (`sound_load`, `sound_store`: `Inline/Mem.lean`; `inline_sound_rip`:
`Inline/Rip.lean`).

- `step_of`: `inline_step`'s argument with the class's soundness replaced by `hrun`, what the
  sequence gives after the scopes and `opSem` (`RRel` with the new state, a predicate `P`,
  `rip`, the control `CtlOk`).
- `load_step`, `store_step`, `rip_step`: the R step against the sequence on `rax`. `load` and
  `store` keep `MemRel`; the scopes keep it (`memRel_foldlM`, scopes below `2^62` bytes), so it
  is assumed of `s`. `FrameApart`, `MemDisjoint`, `Private` and `Globals` are assumed of the
  state after the scopes (`AfterScopes`): that the scopes keep them isn't proved. A store's
  `RRel` after needs its allocation count kept (`store_allocs`: `store` sets one allocation).
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
known); `FrameApart`/`MemDisjoint`/`Private`/`Globals` after the scopes; `MemRel` after a
rip-relative address step (its frame write is like `load`'s, but isn't proved here).
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
    (hsz : ∀ sc ∈ c.scopesAt s.pc, sc.size < 2 ^ 62) (hap : AfterScopes c s (FrameApart · x))
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
    hok.shape hseq hn ho hr1.rel (hpriv vals hn s1 hsc) hm1 (hap s1 hsc)
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
  have hok' := sequence_ok hext hseq
  have hsafe : ∀ it ∈ cand, cacheSafe it = true := fun it hit => by
    have := hok' it hit; simp only [seqItemOk, Bool.and_eq_true] at this; exact this.1
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
    · have hm : ∀ it ∈ cand, cacheSafe it = true ∧ isMulQ it = false := fun it hit =>
        ⟨hsafe it hit, by cases e : isMulQ it; rfl; exact absurd ⟨it, hit, e⟩ hq⟩
      obtain ⟨z, hz, hze⟩ := execItems_swap ctx hc hb cand (swapS xr x) x1 x.rip hm hx1
      rw [swapS_swapS, jump_rip] at hz
      refine ⟨z, ?_, ?_, ?_, ?_⟩
      · rw [List.map_congr_left (fun it hit => ren_eq_swap hc hb (by
          have := hok' it hit; simp only [seqItemOk, Bool.and_eq_true] at this; exact this.2))]
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
    (hsz : ∀ sc ∈ c.scopesAt s.pc, sc.size < 2 ^ 62) (hap : AfterScopes c s (FrameApart · x))
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
        (fun s1 h1 => frameApart_congr (swapS_rbp hb x) (hap s1 h1)) hpriv hi hf hok hseq h
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

end Ryo.Proofs.CacheMem
