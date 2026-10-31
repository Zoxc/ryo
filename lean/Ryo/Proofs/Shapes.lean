/-
Ryo.Proofs.Shapes — one R step of each non-inline shape against its canonical x86 items
(aot.md §C2 "Shapes", toward M3 `decode_sound`): R's `step` (the scopes, then `stepView`:
`view`/`unpack`, `opSem`, `Then.succ`; or `jmp`) and the items `DecodeReduced.insn` accepts for
it (`thenSeq`'s tails), composing `Handler.handler_op_sound` / `br_tail` with the scopes
(`rrel_scopes`, `memRel_foldlM`).

- `handler_core`: the common part for any `then`: after the scopes, `handler_op_sound`'s
  return gives a choice whose `opSem` result is related (`HRel`, `EscWF`), and R's step for it
  is `.step` at `Then.succ`'s successor, or an error when `Then.succ` is `none`.
- `handler_step_op`:`handler h args next` of shape `op` or `lpad`, items `setup ++ [call h]`.
  From `RRel s x` and `MemRel`, the items reach the handler (`x1`); if R can step for some
  choice, the handler returns; and for every return `x'` there is a choice `ch` with
  `R.step c s ch = .ok (.step s')`, `RRel s' x'`, `MemRel s'.st x'`, `s'.pc = s.pc + 1`, `rip`
  past the items, `rsp` and the callee-saved registers of `x`.
- `handler_step_br`: `handler h args (branch neg t)` of shape `br`, then the tail `test al, al;
  jz/jnz tgt`: as `op`, the returned `bool` `b` choosing `s'.pc = t` and `rip` at the target
  exactly when `b != neg`, else the next instruction and `rip` past the tail.
- `handler_step_trap`: `handler h args trap` (not `resume`), then `ud2`: each return faults
  with `#UD` at the `ud2`, and R for the matching choice is an error (`Then.succ` of `trap` is
  `none`: R's step is `illFormed`), so a trap handler that returns has no R step either.
- `jmp_step`: a native `jmp t`, item `jmp tgt`: the scopes keep `RRel`/`MemRel`, `s'.pc = t`,
  `rip` at the target, nothing else changed.
- `unreachable_step`: a bare `ud2` faults with `#UD`; R's step throws `Stop.unreachable`.

**Hypotheses.** Targets: R's targets are instruction indices, the x86 ones offsets from
`ctx.base`; `pos : Nat → BitVec 32` is the placement (`pos t` is where instruction `t`'s items
start, the offset the decoder read the branch with), assumed as `pos t = tgt`. The pre-step
facts about the state after the scopes (`NoUB`, `StackApart`) are taken about `s1`, the
scopes' result (`hsc`). `OpFacts h`, of the opcode tables and `opSem`, is a hypothesis here
(proved for every opcode by `opFacts`, `RyoProofs/OpFacts.lean`, outside the default build): the
control result has the shape's form (`next` for `op`/`lpad`, a `bool` for `br`) and `opSem`
keeps `EscWF` (it keeps the escaped objects and the number of allocations,
`Ryo/Proofs/OpFacts.lean`). Scopes are below
`2^62` bytes (`memRel_foldlM`).
-/
import Ryo.Proofs.Handler
import Ryo.Proofs.Step
import Ryo.Proofs.ScopeMem

set_option linter.constructorNameAsVariable false

namespace Ryo.Proofs.Shapes

open Ryo.Spec Ryo.Vm Ryo.Vm.OpSem Ryo.X86 Ryo.Vm.Asm Ryo.Proofs.Inline Ryo.Proofs.Scope
open Ryo.Proofs.Handler Ryo.Proofs.ScopeMem
open Ryo.Proofs.Counter (CalleeSaved)

/-- The control result `opSem` gives for an opcode of shape `sh`: `next` for `op`/`lpad`, a
`bool` for `br`. -/
def CtlFits (sh : Shape) (c : Control) : Prop :=
  ((sh = .op ∨ sh = .lpad) → c = .next) ∧ (sh = .br → ∃ b, c = .branch b)

/-- What the step needs of `opSem h` (a hypothesis here, proved by `opFacts`; see the module
comment). -/
structure OpFacts (h : Full.Opcode) : Prop where
  ctl : ∀ vals st ch ctl st', opSem h vals st ch = .ok (ctl, st') → CtlFits h.info.shape ctl
  escWF : ∀ vals st ch ctl st', opSem h vals st ch = .ok (ctl, st') → EscWF st → EscWF st'

set_option maxRecDepth 100000 in
theorem resume_shape : Full.Opcode.resume.info.shape = .trap := by decide

set_option maxRecDepth 100000 in
theorem unreachable_shape : Full.Opcode.unreachable.info.shape = .trap := by decide

set_option maxRecDepth 100000 in
theorem unreachable_operands : Full.Opcode.unreachable.info.operands = [] := by decide

theorem ud2_fault (ctx : Ctx) (x : X86.State) : execItems ctx [.ud2] x = .error .ud := by
  simp [execItems, Item.exec, throw, throwThe, MonadExceptOf.throw]

set_option maxRecDepth 100000 in
theorem unreachable_ne_resume : (Full.Opcode.unreachable == Full.Opcode.resume) = false := by
  decide

theorem view_unreachable {mode : Ryo.Obj.Mode} {ρ : R.Addrs} {op : Reduced.Opcode}
    (hf : op.full = some .unreachable) :
    R.view mode ρ (.native op []) = some ⟨.unreachable, [], some .trap⟩ := by
  have hop : R.opShape Full.Opcode.unreachable = true := by
    unfold R.opShape; rw [unreachable_shape]
  have hc : R.nativeCtl Full.Opcode.unreachable [] = some .trap := by
    unfold R.nativeCtl; rw [unreachable_shape]; rfl
  simp only [R.view, hf, Option.bind_eq_bind, Option.bind_some, unreachable_operands, hop, hc,
    List.length_nil, bne_self_eq_false, Bool.false_eq_true, ↓reduceIte, List.zip_nil_left]
  rfl

/-! ### Relations up to `rip` and flags -/

theorem rel_congr {st : OpSem.State} {x y : X86.State} (hr : y.regs = x.regs)
    (hm : y.mem = x.mem) (h : Rel st x) : Rel st y := by
  have hf : ∀ o, fpAddr y o = fpAddr x o := fun o => by simp [fpAddr, State.reg, hr]
  exact ⟨fun o h1 h2 b hb => by rw [hf, hm]; exact h.frame o h1 h2 b hb,
    fun e he a ha => by rw [hf]; exact h.layout e he a ha,
    fun p hp => by rw [hf]; exact h.zeroSized p hp⟩

theorem memRel_congr {st : OpSem.State} {x y : X86.State} (hm : y.mem = x.mem)
    (h : MemRel st x) : MemRel st y :=
  fun id a hg hl i hi => by rw [hm]; exact h id a hg hl i hi

/-! ### R's step of a handler call -/

theorem step_handler {c : R.Code} {s s1 : R.RState} {ch : OpSem.Choice} {h : Full.Opcode}
    {args : List R.Arg} {t : R.Then Nat} (hi : c.d.insns[s.pc]? = some (.handler h args t))
    (hsc : (c.scopesAt s.pc).foldlM R.applyScope s = .ok s1) :
    R.step c s ch = R.stepView c s1 (.handler h args t) ch := by
  unfold R.step
  simp only [hi, bind, Except.bind, hsc]

theorem stepView_succ {c : R.Code} {s1 : R.RState} {ch : OpSem.Choice} {h : Full.Opcode}
    {args : List R.Arg} {t : R.Then Nat} {vals : Operands} {ctl : Control} {st' : OpSem.State}
    {pc : Nat} (hv : R.view c.mode c.ρ (.handler h args t) = some ⟨h, vals, some t⟩)
    (hres : h ≠ .resume) (hun : h ≠ .unreachable) (hop : opSem h vals s1.st ch = .ok (ctl, st'))
    (hp : t.succ s1.pc ctl = some pc) :
    R.stepView c s1 (.handler h args t) ch = .ok (.step { s1 with pc, st := st' }) := by
  unfold R.stepView
  simp only [hv, bind, Except.bind, beq_iff_eq, hres, hun, ↓reduceIte, hop, hp, pure, Except.pure]

theorem stepView_none {c : R.Code} {s1 : R.RState} {ch : OpSem.Choice} {h : Full.Opcode}
    {args : List R.Arg} {t : R.Then Nat} {vals : Operands} {ctl : Control} {st' : OpSem.State}
    (hv : R.view c.mode c.ρ (.handler h args t) = some ⟨h, vals, some t⟩)
    (hres : h ≠ .resume) (hun : h ≠ .unreachable) (hop : opSem h vals s1.st ch = .ok (ctl, st'))
    (hp : t.succ s1.pc ctl = none) :
    ∃ e, R.stepView c s1 (.handler h args t) ch = .error e := by
  unfold R.stepView
  simp only [hv, bind, Except.bind, beq_iff_eq, hres, hun, ↓reduceIte, hop, hp, illFormed,
    throw, throwThe, MonadExceptOf.throw]
  exact ⟨_, rfl⟩

theorem opSem_of_stepView {c : R.Code} {s1 : R.RState} {ch : OpSem.Choice} {h : Full.Opcode}
    {args : List R.Arg} {t : R.Then Nat} {vals : Operands} {o : R.Out}
    (hv : R.view c.mode c.ρ (.handler h args t) = some ⟨h, vals, some t⟩)
    (hres : h ≠ .resume) (hun : h ≠ .unreachable)
    (ho : R.stepView c s1 (.handler h args t) ch = .ok o) :
    ∃ r, opSem h vals s1.st ch = .ok r := by
  unfold R.stepView at ho
  simp only [hv, bind, Except.bind, beq_iff_eq, hres, hun, ↓reduceIte] at ho
  cases hop : opSem h vals s1.st ch with
  | error e => simp [hop] at ho
  | ok r => exact ⟨r, rfl⟩

/-- The generic part of a handler call's step: `handler_op_sound` after the scopes, with R's
step for the returned choice. -/
theorem handler_core (ctx : Ctx) {c : R.Code} {s s1 : R.RState} {x : X86.State}
    {Owned : BitVec 64 → Prop} {lo : BitVec 64} {Ret : Full.Opcode → X86.State → X86.State → Prop}
    (hC : HandlerContract ctx c.ρ c.mode Owned lo Ret) (hl : Linked ctx c.ρ)
    {h : Full.Opcode} {n : Nat} {args : List R.Arg} {t : R.Then Nat} {vals : Operands}
    {items : List Item} (hn : Full.Opcode.ofNat? n = some h) (hh : h.hasHandler = true)
    (hF : OpFacts h) (hres : h ≠ .resume) (hun : h ≠ .unreachable)
    (hi : c.d.insns[s.pc]? = some (.handler h args t))
    (hu : R.unpack c.ρ h c.mode args = some vals)
    (hv : R.view c.mode c.ρ (.handler h args t) = some ⟨h, vals, some t⟩)
    (hs : setupItems c.mode args = some items) (hreg : args.length ≤ (handlerRegs c.mode.pe).length)
    (hr : RRel s x) (hm : MemRel s.st x) (hsz : ∀ sc ∈ c.scopesAt s.pc, sc.size < 2 ^ 62)
    (hsc : (c.scopesAt s.pc).foldlM R.applyScope s = .ok s1)
    (hno : NoUB h vals s1.st) (hap : StackApart lo s1.st x) (hlo : lo.toNat + 8 ≤ x.rsp.toNat) :
    ∃ x1, execItems ctx (items ++ [Item.call (.handler n)]) x = .ok x1 ∧
      ((∃ ch o, R.step c s ch = .ok o) → ∃ x', Ret h x1 x') ∧
      ∀ x', Ret h x1 x' → ∃ ch ctl st', opSem h vals s1.st ch = .ok (ctl, st') ∧
        HRel st' x' ∧ EscWF st' ∧ CtlIn ctl x' ∧ CtlFits h.info.shape ctl ∧
        x'.reg .rbp = BitVec.ofNat 64 s1.fp ∧ s1.pc = s.pc ∧
        x'.rsp = x.rsp ∧
        x'.rip = x.rip + BitVec.ofNat 64 ((items ++ [Item.call (.handler n)]).map Item.size).sum ∧
        (∀ i, CalleeSaved i → x'.regs i = x.regs i) ∧
        (∀ pc, t.succ s.pc ctl = some pc →
          R.step c s ch = .ok (.step { s1 with pc, st := st' })) ∧
        (t.succ s.pc ctl = none → ∃ e, R.step c s ch = .error e) := by
  obtain ⟨hr1, hm1⟩ := memRel_foldlM _ hsz hr hm hsc
  have hpc : s1.pc = s.pc := (scopes_keeps _ hsc).pc
  obtain ⟨x1, hx1, hret, hsound⟩ :=
    handler_op_sound ctx hC hl hn hh hu hs hreg ⟨hr1.rel, hm1⟩ hno hap hlo
  refine ⟨x1, hx1, fun ⟨ch, o, ho⟩ => hret ?_, fun x' hR => ?_⟩
  · rw [step_handler hi hsc] at ho
    obtain ⟨r, hop⟩ := opSem_of_stepView hv hres hun ho
    exact ⟨ch, r, hop⟩
  · obtain ⟨ch, ctl, st', hop, hH, hctl, hsp, hrip, hsaved⟩ := hsound x' hR
    have hstep := step_handler (ch := ch) hi hsc
    refine ⟨ch, ctl, st', hop, hH, hF.escWF vals s1.st ch ctl st' hop hr1.wf, hctl,
      ?_, ?_, hpc, hsp, hrip, hsaved, fun pc hp => ?_, fun hp => ?_⟩
    · exact hF.ctl vals s1.st ch ctl st' hop
    · show x'.regs 5 = _
      rw [hsaved 5 (by simp [CalleeSaved])]
      exact hr1.rbp
    · rw [hstep]; exact stepView_succ hv hres hun hop (by rw [hpc]; exact hp)
    · rw [hstep]; exact stepView_none hv hres hun hop (by rw [hpc]; exact hp)

/-! ### The shapes -/

/-- `handler h args next` of shape `op` or `lpad` (see the module comment). -/
theorem handler_step_op (ctx : Ctx) {c : R.Code} {s s1 : R.RState} {x : X86.State}
    {Owned : BitVec 64 → Prop} {lo : BitVec 64} {Ret : Full.Opcode → X86.State → X86.State → Prop}
    (hC : HandlerContract ctx c.ρ c.mode Owned lo Ret) (hl : Linked ctx c.ρ)
    {h : Full.Opcode} {n : Nat} {args : List R.Arg} {vals : Operands} {items : List Item}
    (hn : Full.Opcode.ofNat? n = some h) (hh : h.hasHandler = true)
    (hsh : h.info.shape = .op ∨ h.info.shape = .lpad) (hF : OpFacts h)
    (hi : c.d.insns[s.pc]? = some (.handler h args .next))
    (hu : R.unpack c.ρ h c.mode args = some vals)
    (hs : setupItems c.mode args = some items) (hreg : args.length ≤ (handlerRegs c.mode.pe).length)
    (hr : RRel s x) (hm : MemRel s.st x) (hsz : ∀ sc ∈ c.scopesAt s.pc, sc.size < 2 ^ 62)
    (hsc : (c.scopesAt s.pc).foldlM R.applyScope s = .ok s1)
    (hno : NoUB h vals s1.st) (hap : StackApart lo s1.st x) (hlo : lo.toNat + 8 ≤ x.rsp.toNat) :
    ∃ x1, execItems ctx (items ++ [Item.call (.handler n)]) x = .ok x1 ∧
      ((∃ ch o, R.step c s ch = .ok o) → ∃ x', Ret h x1 x') ∧
      ∀ x', Ret h x1 x' → ∃ ch s', R.step c s ch = .ok (.step s') ∧ RRel s' x' ∧
        MemRel s'.st x' ∧ s'.pc = s.pc + 1 ∧ x'.rsp = x.rsp ∧
        x'.rip = x.rip + BitVec.ofNat 64 ((items ++ [Item.call (.handler n)]).map Item.size).sum ∧
        (∀ i, CalleeSaved i → x'.regs i = x.regs i) := by
  have hres : h ≠ .resume := by
    rintro rfl; rw [resume_shape] at hsh; rcases hsh with hsh | hsh <;> cases hsh
  have hun : h ≠ .unreachable := by
    rintro rfl; rw [unreachable_shape] at hsh; rcases hsh with hsh | hsh <;> cases hsh
  have hv : R.view c.mode c.ρ (.handler h args .next) = some ⟨h, vals, some .next⟩ := by
    rcases hsh with hsh | hsh <;> simp [R.view, hh, hu, hsh]
  obtain ⟨x1, hx1, hret, hall⟩ := handler_core ctx hC hl hn hh hF hres hun hi hu hv hs hreg hr hm hsz
    hsc hno hap hlo
  refine ⟨x1, hx1, hret, fun x' hR => ?_⟩
  obtain ⟨ch, ctl, st', -, hH, hwf, -, hfit, hrbp, -, hsp, hrip, hsaved, hok, -⟩ := hall x' hR
  have hctl : ctl = .next := hfit.1 hsh
  subst hctl
  exact ⟨ch, _, hok _ rfl, ⟨hH.rel, hrbp, hwf⟩, hH.mem, rfl, hsp, hrip, hsaved⟩

/-- `handler h args (branch neg t)` of shape `br` with its tail `test al, al; jz/jnz tgt`
(`pos t = tgt`: see the module comment). -/
theorem handler_step_br (ctx : Ctx) {c : R.Code} {s s1 : R.RState} {x : X86.State}
    {Owned : BitVec 64 → Prop} {lo : BitVec 64} {Ret : Full.Opcode → X86.State → X86.State → Prop}
    (hC : HandlerContract ctx c.ρ c.mode Owned lo Ret) (hl : Linked ctx c.ρ)
    {h : Full.Opcode} {n : Nat} {args : List R.Arg} {vals : Operands} {items : List Item}
    {neg : Bool} {t : Nat} {tgt : BitVec 32} {long : Bool} (pos : Nat → BitVec 32)
    (hpos : pos t = tgt)
    (hn : Full.Opcode.ofNat? n = some h) (hh : h.hasHandler = true)
    (hsh : h.info.shape = .br) (hF : OpFacts h)
    (hi : c.d.insns[s.pc]? = some (.handler h args (.branch neg t)))
    (hu : R.unpack c.ρ h c.mode args = some vals)
    (hs : setupItems c.mode args = some items) (hreg : args.length ≤ (handlerRegs c.mode.pe).length)
    (hr : RRel s x) (hm : MemRel s.st x) (hsz : ∀ sc ∈ c.scopesAt s.pc, sc.size < 2 ^ 62)
    (hsc : (c.scopesAt s.pc).foldlM R.applyScope s = .ok s1)
    (hno : NoUB h vals s1.st) (hap : StackApart lo s1.st x) (hlo : lo.toNat + 8 ≤ x.rsp.toNat) :
    ∃ x1, execItems ctx (items ++ [Item.call (.handler n)]) x = .ok x1 ∧
      ((∃ ch o, R.step c s ch = .ok o) → ∃ x', Ret h x1 x') ∧
      ∀ x', Ret h x1 x' → ∃ ch s' x'' b, R.step c s ch = .ok (.step s') ∧
        execItems ctx [.testAl, .branch (if neg then .z else .nz) tgt long] x' = .ok x'' ∧
        RRel s' x'' ∧ MemRel s'.st x'' ∧
        s'.pc = (if b != neg then t else s.pc + 1) ∧
        x''.rip = (if b != neg then ctx.base + (pos t).setWidth 64
          else x.rip + BitVec.ofNat 64 ((items ++ [Item.call (.handler n),
            .testAl, .branch (if neg then .z else .nz) tgt long]).map Item.size).sum) ∧
        x''.rsp = x.rsp ∧ (∀ i, CalleeSaved i → x''.regs i = x.regs i) := by
  have hres : h ≠ .resume := by rintro rfl; rw [resume_shape] at hsh; cases hsh
  have hun : h ≠ .unreachable := by rintro rfl; rw [unreachable_shape] at hsh; cases hsh
  have hv : R.view c.mode c.ρ (.handler h args (.branch neg t)) =
      some ⟨h, vals, some (.branch neg t)⟩ := by
    simp [R.view, hh, hu, hsh]
  obtain ⟨x1, hx1, hret, hall⟩ := handler_core ctx hC hl hn hh hF hres hun hi hu hv hs hreg hr hm hsz
    hsc hno hap hlo
  refine ⟨x1, hx1, hret, fun x' hR => ?_⟩
  obtain ⟨ch, ctl, st', -, hH, hwf, hcin, hfit, hrbp, -, hsp, hrip, hsaved, hok, -⟩ := hall x' hR
  obtain ⟨b, rfl⟩ := hfit.2 hsh
  obtain ⟨x'', hx'', hregs, hmem, -, hrip''⟩ := br_tail ctx b neg tgt long x' hcin
  have hrsp : x''.rsp = x'.rsp := by simp [State.rsp, State.reg, hregs]
  refine ⟨ch, _, x'', b, hok _ rfl, hx'', ⟨rel_congr hregs hmem hH.rel, ?_, hwf⟩,
    memRel_congr hmem hH.mem, rfl, ?_, hrsp.trans hsp, fun i hi => by rw [hregs]; exact hsaved i hi⟩
  · simp only [State.reg, hregs] at hrbp ⊢; exact hrbp
  · rw [hrip'', hrip, hpos]
    split
    · rfl
    · simp [BitVec.add_assoc, BitVec.ofNat_add]

/-- `handler h args trap` then `ud2` (`h` not `resume`): each return faults at the `ud2`, and R
for that return's choice errors (`Then.succ` of `trap` is `none`). -/
theorem handler_step_trap (ctx : Ctx) {c : R.Code} {s s1 : R.RState} {x : X86.State}
    {Owned : BitVec 64 → Prop} {lo : BitVec 64} {Ret : Full.Opcode → X86.State → X86.State → Prop}
    (hC : HandlerContract ctx c.ρ c.mode Owned lo Ret) (hl : Linked ctx c.ρ)
    {h : Full.Opcode} {n : Nat} {args : List R.Arg} {vals : Operands} {items : List Item}
    (hn : Full.Opcode.ofNat? n = some h) (hh : h.hasHandler = true)
    (hsh : h.info.shape = .trap) (hres : h ≠ .resume) (hun : h ≠ .unreachable) (hF : OpFacts h)
    (hi : c.d.insns[s.pc]? = some (.handler h args .trap))
    (hu : R.unpack c.ρ h c.mode args = some vals)
    (hs : setupItems c.mode args = some items) (hreg : args.length ≤ (handlerRegs c.mode.pe).length)
    (hr : RRel s x) (hm : MemRel s.st x) (hsz : ∀ sc ∈ c.scopesAt s.pc, sc.size < 2 ^ 62)
    (hsc : (c.scopesAt s.pc).foldlM R.applyScope s = .ok s1)
    (hno : NoUB h vals s1.st) (hap : StackApart lo s1.st x) (hlo : lo.toNat + 8 ≤ x.rsp.toNat) :
    ∃ x1, execItems ctx (items ++ [Item.call (.handler n)]) x = .ok x1 ∧
      ((∃ ch o, R.step c s ch = .ok o) → ∃ x', Ret h x1 x') ∧
      ∀ x', Ret h x1 x' → execItems ctx [.ud2] x' = .error .ud ∧
        ∃ ch ctl st', opSem h vals s1.st ch = .ok (ctl, st') ∧ ∃ e, R.step c s ch = .error e := by
  have hv : R.view c.mode c.ρ (.handler h args .trap) = some ⟨h, vals, some .trap⟩ := by
    simp [R.view, hh, hu, hsh]
  obtain ⟨x1, hx1, hret, hall⟩ := handler_core ctx hC hl hn hh hF hres hun hi hu hv hs hreg hr hm hsz
    hsc hno hap hlo
  refine ⟨x1, hx1, hret, fun x' hR => ⟨ud2_fault ctx x', ?_⟩⟩
  obtain ⟨ch, ctl, st', hop, -, -, -, -, -, -, -, -, -, -, herr⟩ := hall x' hR
  exact ⟨ch, ctl, st', hop, herr (by cases ctl <;> rfl)⟩

/-- A native `jmp t` against `jmp tgt` (`pos t = tgt`). -/
theorem jmp_step (ctx : Ctx) {c : R.Code} {s s' : R.RState} {x : X86.State}
    {ch : OpSem.Choice} {op : Reduced.Opcode} {f : Full.Opcode} {t : Nat} {tgt : BitVec 32}
    {long : Bool} (pos : Nat → BitVec 32) (hpos : pos t = tgt)
    (hi : c.d.insns[s.pc]? = some (.native op [.target t])) (hf : op.full = some f)
    (hsh : f.info.shape = .jmp) (hr : RRel s x) (hm : MemRel s.st x)
    (hsz : ∀ sc ∈ c.scopesAt s.pc, sc.size < 2 ^ 62)
    (h : R.step c s ch = .ok (.step s')) :
    ∃ x', execItems ctx [.branch .always tgt long] x = .ok x' ∧ RRel s' x' ∧
      MemRel s'.st x' ∧ s'.pc = t ∧ x'.rip = ctx.base + (pos t).setWidth 64 ∧
      x'.regs = x.regs ∧ x'.mem = x.mem := by
  unfold R.step at h
  simp only [hi, bind, Except.bind] at h
  cases hsc : (c.scopesAt s.pc).foldlM R.applyScope s with
  | error e => simp [hsc] at h
  | ok s1 =>
    simp only [hsc, hf] at h
    rw [hsh] at h
    simp only [pure, Except.pure, Except.ok.injEq, R.Out.step.injEq] at h
    subst h
    obtain ⟨hr1, hm1⟩ := memRel_foldlM _ hsz hr hm hsc
    let x' := (x.jump (x.rip + BitVec.ofNat 64 (Item.branch .always tgt long).size)).jump
      (ctx.base + tgt.setWidth 64)
    have hx : execItems ctx [.branch .always tgt long] x = .ok x' := by
      simp [x', execItems, Item.exec, Cond.eval, bind, Except.bind, pure, Except.pure]
    exact ⟨x', hx, ⟨rel_congr (x := x) rfl rfl hr1.rel, hr1.rbp, hr1.wf⟩,
      memRel_congr (x := x) rfl hm1, rfl, by simp [x', State.jump, hpos], rfl, rfl⟩

/-- A bare `ud2` (`unreachable`): x86 faults with `#UD`; R's step throws `unreachable`. -/
theorem unreachable_step (ctx : Ctx) {c : R.Code} {s s1 : R.RState} {x : X86.State}
    {ch : OpSem.Choice} {op : Reduced.Opcode}
    (hi : c.d.insns[s.pc]? = some (.native op [])) (hf : op.full = some .unreachable)
    (hsc : (c.scopesAt s.pc).foldlM R.applyScope s = .ok s1) :
    execItems ctx [.ud2] x = .error .ud ∧ R.step c s ch = .error .unreachable := by
  refine ⟨ud2_fault ctx x, ?_⟩
  have hsh := unreachable_shape
  have hlen := unreachable_operands
  unfold R.step
  simp only [hi, bind, Except.bind, hsc, hf]
  simp only [hsh]
  unfold R.stepView
  simp only [view_unreachable hf, unreachable_ne_resume, bind, Except.bind, Bool.false_eq_true,
    ↓reduceIte, beq_self_eq_true]
  rfl

end Ryo.Proofs.Shapes
