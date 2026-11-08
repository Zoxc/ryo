import Ryo.Proofs.DecodeSound.Basic
import Ryo.Proofs.NoArgCursor
import Ryo.Proofs.DSWork.Island
import Ryo.Proofs.OpFacts
import Ryo.Proofs.Discharge.PadsLinked
import Ryo.Proofs.HandlerStackArg
import Ryo.Proofs.Discharge.SpDisp
import Ryo.Proofs.DecodeSound.Region

set_option linter.constructorNameAsVariable false

namespace Ryo.Proofs.DecodeSound

open Ryo.Spec Ryo.Vm Ryo.Vm.OpSem Ryo.X86 Ryo.Vm.Asm Ryo.Vm.R
open Ryo.Proofs.Inline Ryo.Proofs.Scope Ryo.Proofs.ScopeMem Ryo.Proofs.RegCache
open Ryo.Proofs.DecodeLink Ryo.Proofs.FrameBounds Ryo.Proofs.CacheMem
open Ryo.Proofs.Counter (CalleeSaved InStack TripContract)
open Ryo.Proofs.ArgRet (ArgsRel RetRel)
open Ryo.Proofs.Call (WorldRel Saved EntryAt CallContract)
open Ryo.Proofs.Island (IslandContract)

/-! ### The scopes never fail with `noBehavior` -/

/-- An error that isn't a choice outside the allowed set. -/
def handler_NotNB (e : Stop) : Prop := ∀ m, e ≠ .noBehavior m

theorem handler_illFormed_notNB (m : String) : handler_NotNB (.illFormed m) := by
  intro m' h; cases h

theorem handler_mapM_err {α β : Type} {f : α → OpSem.M β} :
    ∀ {l : List α} {e : Stop}, (∀ a e', f a = .error e' → handler_NotNB e') →
      l.mapM f = .error e → handler_NotNB e
  | [], e, _, h => by simp [pure, Except.pure] at h
  | a :: l, e, hf, h => by
    simp only [List.mapM_cons, bind, Except.bind] at h
    cases ha : f a with
    | error e' => simp only [ha] at h; cases h; exact hf a _ ha
    | ok b =>
      simp only [ha] at h
      cases hl : l.mapM f with
      | error e'' => simp only [hl] at h; cases h; exact handler_mapM_err hf hl
      | ok bs => simp [hl, pure, Except.pure] at h

theorem handler_foldlM_err {α σ : Type} {f : σ → α → OpSem.M σ} :
    ∀ {l : List α} {s : σ} {e : Stop}, (∀ s a e', f s a = .error e' → handler_NotNB e') →
      l.foldlM f s = .error e → handler_NotNB e
  | [], s, e, _, h => by simp [pure, Except.pure] at h
  | a :: l, s, e, hf, h => by
    simp only [List.foldlM_cons, bind, Except.bind] at h
    cases ha : f s a with
    | error e' => simp only [ha] at h; cases h; exact hf s a _ ha
    | ok s1 => simp only [ha] at h; exact handler_foldlM_err hf h

theorem handler_byteAt_err {st : OpSem.State} {o : Int} {e : Stop}
    (h : st.byteAt o = .error e) : handler_NotNB e := by
  unfold OpSem.State.byteAt at h
  split at h
  · cases h
  · split at h
    · split at h
      · cases h; exact handler_illFormed_notNB _
      · split at h
        · cases h
        · cases h; exact handler_illFormed_notNB _
    · cases h; exact handler_illFormed_notNB _

theorem handler_readFrame_err {st : OpSem.State} {off : Int} {n : Nat} {e : Stop}
    (h : st.readFrame off n = .error e) : handler_NotNB e :=
  handler_mapM_err (fun _ _ h' => handler_byteAt_err h') h

theorem handler_writeFrame_err {st : OpSem.State} {off : Int} {bs : List AbstractByte} {e : Stop}
    (h : st.writeFrame off bs = .error e) : handler_NotNB e := by
  unfold OpSem.State.writeFrame at h
  cases hm : st.writeEscaped off bs with
  | ok m => simp [hm, bind, Except.bind, pure, Except.pure] at h
  | error e' =>
    simp only [hm, bind, Except.bind] at h
    cases h
    unfold OpSem.State.writeEscaped at hm
    refine handler_foldlM_err (fun mem p e2 h2 => ?_) hm
    simp only at h2
    split at h2
    · cases h2
    · split at h2
      · cases h2; exact handler_illFormed_notNB _
      · cases h2

theorem handler_applyScope_err {s : R.RState} {sc : R.Scope} {e : Stop}
    (h : R.applyScope s sc = .error e) : handler_NotNB e := by
  unfold R.applyScope at h
  split at h
  · unfold R.escape at h
    simp only at h
    split at h
    · cases h
    split at h
    · cases h; exact handler_illFormed_notNB _
    unfold R.frameAddr at h
    simp only [bind, Except.bind] at h
    split at h
    · rename_i e1 he1
      split at he1
      · cases he1; cases h; exact handler_illFormed_notNB _
      · cases he1
    · simp only [pure, Except.pure] at h
      split at h
      · cases h; exact handler_illFormed_notNB _
      split at h
      · cases h; exact handler_illFormed_notNB _
      split at h
      · rename_i e2 hr; cases h; exact handler_readFrame_err hr
      · cases h
  · unfold R.storageEnd at h
    simp only [bind, Except.bind] at h
    split at h
    · rename_i e1 he1; cases h; exact handler_writeFrame_err he1
    · simp [pure, Except.pure] at h
  · cases h

theorem handler_scopes_err {l : List R.Scope} {s : R.RState} {e : Stop}
    (h : l.foldlM R.applyScope s = .error e) : handler_NotNB e :=
  handler_foldlM_err (fun _ _ _ h' => handler_applyScope_err h') h

/-! ### R's side of a handler call, from `RSafe` -/

theorem handler_view {mode : Ryo.Obj.Mode} {ρ : R.Addrs} {h : Full.Opcode} {args : List R.Arg}
    {t : R.Then Nat} {v : R.View} (hv : R.view mode ρ (.handler h args t) = some v) :
    ∃ vals, R.unpack ρ h mode args = some vals ∧ v = ⟨h, vals, some t⟩ := by
  cases hu : R.unpack ρ h mode args with
  | none => simp [R.view, hu] at hv
  | some vals =>
    refine ⟨vals, rfl, ?_⟩
    simp only [R.view, hu] at hv
    split at hv
    · cases hv
    · split at hv <;> simp at hv <;> (try split at hv) <;> simp_all

/-- What `RSafe` gives of a handler call `handler h args t` (not `resume`, not `unreachable`):
the scopes succeed, the arguments unpack, `opSem` has no UB, and each of its results, with PE's
home space cleared (`R.clearHome`, which then succeeds), is an R step to `Then.succ`'s
successor. -/
theorem handler_rside {Safe : R.Query → Prop} {c : R.Code} {s : R.RState} {h : Full.Opcode}
    {args : List R.Arg} {t : R.Then Nat} (hi : c.d.insns[s.pc]? = some (.handler h args t))
    (hsafe : RSafe Safe c s) (hres : h ≠ .resume) (hun : h ≠ .unreachable) :
    ∃ s1 vals, (c.scopesAt s.pc).foldlM R.applyScope s = .ok s1 ∧
      R.unpack c.ρ h c.mode args = some vals ∧ Handler.NoUB h vals s1.st ∧
      ∀ ch ctl st', opSem h vals s1.st ch = .ok (ctl, st') → ∃ st'' pc,
        R.clearHome c.mode.pe args.length (-(c.d.frameSize : Int)) st' = .ok st'' ∧
        t.succ s.pc ctl = some pc ∧ R.step c s ch = .ok (.step { s1 with pc, st := st'' }) := by
  have hE : ∀ ch e, R.step c s ch = .error e → handler_NotNB e → False := fun ch e h1 h2 => by
    obtain ⟨m, hm⟩ := hsafe.1 ch e h1; exact h2 m hm
  cases hsc : (c.scopesAt s.pc).foldlM R.applyScope s with
  | error e =>
    exfalso
    refine hE {} e ?_ (handler_scopes_err hsc)
    unfold R.step; simp only [hi, bind, Except.bind, hsc]
  | ok s1 =>
    have hst := fun ch => Shapes.step_handler (ch := ch) hi hsc
    have hpc : s1.pc = s.pc := (scopes_keeps _ hsc).pc
    cases hv : R.view c.mode c.ρ (.handler h args t) with
    | none =>
      exfalso
      obtain ⟨msg, hmsg⟩ : ∃ msg, R.stepView c s1 (.handler h args t) {} =
          .error (.illFormed msg) := by
        unfold R.stepView; simp only [hv]; exact ⟨_, rfl⟩
      exact hE {} _ ((hst {}).trans hmsg) (handler_illFormed_notNB _)
    | some v =>
      obtain ⟨vals, hu, rfl⟩ := handler_view hv
      refine ⟨s1, vals, rfl, hu, fun ch e he => ?_, fun ch ctl st' hop => ?_⟩
      · refine hsafe.1 ch e ((hst ch).trans ?_)
        unfold R.stepView
        simp only [hv, bind, Except.bind, beq_iff_eq, hres, hun, ↓reduceIte, he]
      · cases hcl : R.clearHome c.mode.pe args.length (-(c.d.frameSize : Int)) st' with
        | error e =>
          exfalso
          refine hE ch e ((hst ch).trans ?_) ?_
          · unfold R.stepView
            simp only [hv, bind, Except.bind, beq_iff_eq, hres, hun, ↓reduceIte, hop, hcl]
          · unfold R.clearHome at hcl
            split at hcl
            · exact handler_writeFrame_err hcl
            · simp [pure, Except.pure] at hcl
        | ok st'' =>
        cases hp : t.succ s.pc ctl with
        | none =>
          exfalso
          obtain ⟨msg, hmsg⟩ : ∃ msg, R.stepView c s1 (.handler h args t) ch =
              .error (.illFormed msg) := by
            unfold R.stepView
            simp only [hv, bind, Except.bind, beq_iff_eq, hres, hun, ↓reduceIte, hop, hcl, hpc,
              hp]
            exact ⟨_, rfl⟩
          exact hE ch _ ((hst ch).trans hmsg) (handler_illFormed_notNB _)
        | some pc =>
          exact ⟨st'', pc, rfl, rfl, (hst ch).trans
            (Shapes.stepView_succ hv hres hun hop hcl (by rw [hpc]; exact hp))⟩

/-! ### The x86 side: the setup and the call -/

theorem handler_push_other (lo sp a : BitVec 64) (hlo : lo.toNat + 8 ≤ sp.toNat)
    (ha : ¬ InStack lo sp a) : 8 ≤ (a - (sp - 8)).toNat := by
  simp only [InStack] at ha
  have hsp : (sp - 8).toNat = sp.toNat - 8 := by
    rw [BitVec.toNat_sub]; have := sp.isLt; simp; omega
  rw [BitVec.toNat_sub, hsp]
  have := a.isLt; have := sp.isLt
  by_cases h1 : lo.toNat ≤ a.toNat
  · have h2 : sp.toNat ≤ a.toNat := by omega
    omega
  · rw [Nat.mod_eq_of_lt (by omega)]
    omega

/-- The setup and `call h` (as `Handler.handler_op_sound`, with the state at the handler's
entry exposed): at the handler, the arguments in place, the relations kept. -/
theorem handler_call {ρ : R.Addrs} {mode : Ryo.Obj.Mode} {lo : BitVec 64} (ctx : Ctx)
    (hl : Handler.Linked ctx ρ) {h : Full.Opcode} {n : Nat} (hn : Full.Opcode.ofNat? n = some h)
    {args : List R.Arg} {items : List Item} (hs : Handler.setupItems mode args = some items)
    (hreg : args.length ≤ (handlerRegs mode.pe).length)
    {st : OpSem.State} {x : X86.State} (hr : Handler.HRel st x) (hap : Handler.StackApart lo st x)
    (hlo : lo.toNat + 8 ≤ x.rsp.toNat) :
    ∃ x2, execItems ctx (items ++ [Item.call (.handler n)]) x = .ok x2 ∧
      Handler.AtHandler ctx h x2 ∧ Handler.ArgsIn ρ mode.pe x2 x2 args ∧ Handler.HRel st x2 ∧
      x2.reg .rbp = x.reg .rbp ∧ x2.rsp = x.rsp - 8 ∧
      (∀ a, ¬ InStack lo x.rsp a → x2.mem a = x.mem a) := by
  obtain ⟨x1, he1, hargs, hm1, hx1, hr1, hrip1⟩ := Handler.exec_setup ctx ρ mode args items x hs hreg hl
  have hkeep : ∀ i : Fin 16, (i = 0 ∨ i = 4 ∨ CalleeSaved i) → x1.regs i = x.regs i := by
    intro i hi
    apply hr1
    intro r hr
    simp only [X86.argRegs, List.mem_cons, List.not_mem_nil, or_false] at hr
    rcases hi with rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl <;>
      rcases hr with rfl | rfl | rfl | rfl | rfl | rfl <;> decide
  let next := x1.rip + BitVec.ofNat 64 (Item.call (.handler n)).size
  let x2 := ((x1.jump next).push next).jump (ctx.addrOf (.handler n))
  have hx1sp : x1.rsp = x.rsp := hkeep 4 (by simp)
  have hrsp2 : x2.rsp = x.rsp - 8 := by
    simp [x2, State.rsp, State.reg, State.jump, State.push, State.setMem, State.setReg] at hx1sp ⊢
    rw [hx1sp]
  have hregs2 : ∀ i, i ≠ Reg.rsp.idx → x2.regs i = x1.regs i := by
    intro i hi
    have hi' : i ≠ 4 := hi
    simp [x2, State.jump, State.push, State.setMem, State.setReg, hi']
  have hmem2 : ∀ a, ¬ InStack lo x.rsp a → x2.mem a = x.mem a := by
    intro a ha
    simp only [x2, State.jump, State.push, State.setMem, State.setReg]
    rw [Mem.write_other _ _ _ _ _ (by
      show 8 ≤ (a - (x1.rsp - 8)).toNat
      rw [hx1sp]; exact handler_push_other lo x.rsp a hlo ha), hm1]
  have hrbp : x2.reg .rbp = x.reg .rbp := by
    show x2.regs 5 = x.regs 5
    rw [hregs2 5 (by decide), hkeep 5 (by simp [CalleeSaved])]
  have hrax : x2.reg .rax = x.reg .rax := by
    show x2.regs 0 = x.regs 0
    rw [hregs2 0 (by decide), hkeep 0 (by simp)]
  have hexec : execItems ctx (items ++ [Item.call (.handler n)]) x = .ok x2 := by
    have happ : execItems ctx (items ++ [Item.call (.handler n)]) x =
        (execItems ctx items x >>= execItems ctx [Item.call (.handler n)]) := by
      simp only [execItems, List.foldlM_append]; rfl
    rw [happ, he1, ex_bind_ok', X86.execItems_cons]; rfl
  have hA : Handler.ArgsIn ρ mode.pe x2 x2 args := by
    refine ⟨fun i h1 h2 => ?_, fun h4 hpe => absurd hreg (by rw [hpe]; simp [handlerRegs]; omega)⟩
    have hv : ∀ b, Handler.argVal ρ x2 b = Handler.argVal ρ x b := by
      intro b; cases b <;> simp [Handler.argVal, hrbp, hrax]
    rw [hv, hargs i h1 h2]
    suffices hs : x2.regs ((handlerRegs mode.pe)[i]).idx = x1.regs ((handlerRegs mode.pe)[i]).idx by
      show some (x1.regs _) = some (x2.regs _); rw [hs]
    apply hregs2
    have hm : (handlerRegs mode.pe)[i] ∈ X86.argRegs := Handler.mem_handlerRegs (List.getElem_mem h2)
    generalize (handlerRegs mode.pe)[i] = r at hm ⊢
    simp only [X86.argRegs, List.mem_cons, List.not_mem_nil, or_false] at hm
    rcases hm with rfl | rfl | rfl | rfl | rfl | rfl <;> decide
  have hat : Handler.AtHandler ctx h x2 := ⟨n, hn, by simp [x2, State.jump]⟩
  have hH : Handler.HRel st x2 :=
    let ⟨h1, h2⟩ := hap.rel hr.rel hr.mem hrbp hmem2; ⟨h1, h2⟩
  exact ⟨x2, hexec, hat, hA, hH, hrbp, hrsp2, hmem2⟩

theorem handler_argItem_regs (ctx : Ctx) {mode : Ryo.Obj.Mode} {r : X86.Reg} {a : R.Arg}
    {it : Item} (h : Handler.argItem mode r a = some it) {x y : X86.State}
    (he : it.exec ctx x = .ok y) : ∀ i, i ≠ r.idx → y.regs i = x.regs i := by
  intro i hi
  cases a with
  | fp =>
    simp only [Handler.argItem, fpItem, Option.some.injEq] at h
    split at h <;> subst h <;> simp only [Item.exec] at he <;> cases Switch.except_ok_inj he <;>
      simp [State.setReg, State.jump, hi]
  | exception =>
    simp only [Handler.argItem, Option.some.injEq] at h; subst h
    simp only [Item.exec] at he; cases Switch.except_ok_inj he; simp [State.setReg, State.jump, hi]
  | imm v =>
    simp only [Handler.argItem, Option.some.injEq] at h; subst h
    simp only [Item.exec] at he
    split at he <;> cases Switch.except_ok_inj he <;>
      simp [State.setReg, State.setFlags, State.jump, hi]
  | const _ | data _ | sym _ | ro _ =>
    simp only [Handler.argItem, Handler.argRef, Option.map_some, Option.some.injEq] at h; subst h
    simp only [Item.exec] at he; cases Switch.except_ok_inj he; simp [State.setReg, State.jump, hi]

theorem handler_setup_regs (ctx : Ctx) (mode : Ryo.Obj.Mode) :
    ∀ (args : List R.Arg) (regs : List X86.Reg) (items : List Item) (x y : X86.State),
    (args.zip regs).mapM (fun (a, r) => Handler.argItem mode r a) = some items →
    execItems ctx items x = .ok y → ∀ i : Fin 16, (∀ r ∈ regs, r.idx ≠ i) → y.regs i = x.regs i
  | [], regs, items, x, y, h, he, i, hi => by
    simp only [List.zip_nil_left, List.mapM_nil, pure, Option.some.injEq] at h; subst h
    cases Switch.except_ok_inj he; rfl
  | a :: args, [], items, x, y, h, he, i, hi => by
    simp only [List.zip_nil_right, List.mapM_nil, pure, Option.some.injEq] at h; subst h
    cases Switch.except_ok_inj he; rfl
  | a :: args, r :: regs, items, x, y, h, he, i, hi => by
    simp only [List.zip_cons_cons, List.mapM_cons, bind, Option.bind] at h
    cases hit : Handler.argItem mode r a with
    | none => simp [hit] at h
    | some it =>
      simp only [hit] at h
      cases hrest : (args.zip regs).mapM (fun (a, r) => Handler.argItem mode r a) with
      | none => simp [hrest] at h
      | some its =>
        simp only [hrest, pure, Option.some.injEq] at h
        subst h
        rw [X86.execItems_cons] at he
        cases hy : it.exec ctx x with
        | error e => rw [hy] at he; cases he
        | ok y1 =>
          rw [hy] at he
          rw [handler_setup_regs ctx mode args regs its y1 y hrest he i
            (fun r' hr' => hi r' (List.mem_cons_of_mem _ hr')),
            handler_argItem_regs ctx hit hy i (fun e => hi r (List.mem_cons_self ..) e.symm)]

/-- `handler_call` without the R state: the setup and `call h` reach the handler with the
return address at `rsp`, `rsp` down 8, the callee-saved registers kept and memory kept off the
stack below `rsp`. -/
theorem handler_call_ret {ρ : R.Addrs} {mode : Ryo.Obj.Mode} {lo : BitVec 64} (ctx : Ctx)
    (hl : Handler.Linked ctx ρ) {h : Full.Opcode} {n : Nat} (hn : Full.Opcode.ofNat? n = some h)
    {args : List R.Arg} {items : List Item} (hs : Handler.setupItems mode args = some items)
    (hreg : args.length ≤ (handlerRegs mode.pe).length)
    {x : X86.State} (hlo : lo.toNat + 8 ≤ x.rsp.toNat) :
    ∃ x2, execItems ctx (items ++ [Item.call (.handler n)]) x = .ok x2 ∧
      Handler.AtHandler ctx h x2 ∧ Handler.ArgsIn ρ mode.pe x2 x2 args ∧ x2.rsp = x.rsp - 8 ∧
      (∀ i, Saved mode.pe i → x2.regs i = x.regs i) ∧
      (∀ a, ¬ InStack lo x.rsp a → x2.mem a = x.mem a) ∧
      x2.mem.read64 x2.rsp =
        x.rip + BitVec.ofNat 64 ((items ++ [Item.call (.handler n)]).map Item.size).sum := by
  obtain ⟨x1, he1, hargs, hm1, hx1, hr1, hrip1⟩ := Handler.exec_setup ctx ρ mode args items x hs hreg hl
  have hkeep : ∀ i : Fin 16, (i = 0 ∨ i = 4 ∨ CalleeSaved i) → x1.regs i = x.regs i := by
    intro i hi
    apply hr1
    intro r hr
    simp only [X86.argRegs, List.mem_cons, List.not_mem_nil, or_false] at hr
    rcases hi with rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl <;>
      rcases hr with rfl | rfl | rfl | rfl | rfl | rfl <;> decide
  let next := x1.rip + BitVec.ofNat 64 (Item.call (.handler n)).size
  let x2 := ((x1.jump next).push next).jump (ctx.addrOf (.handler n))
  have hx1sp : x1.rsp = x.rsp := hkeep 4 (by simp)
  have hrsp2 : x2.rsp = x.rsp - 8 := by
    simp [x2, State.rsp, State.reg, State.jump, State.push, State.setMem, State.setReg] at hx1sp ⊢
    rw [hx1sp]
  have hregs2 : ∀ i, i ≠ Reg.rsp.idx → x2.regs i = x1.regs i := by
    intro i hi
    have hi' : i ≠ 4 := hi
    simp [x2, State.jump, State.push, State.setMem, State.setReg, hi']
  have hmem2 : ∀ a, ¬ InStack lo x.rsp a → x2.mem a = x.mem a := by
    intro a ha
    simp only [x2, State.jump, State.push, State.setMem, State.setReg]
    rw [Mem.write_other _ _ _ _ _ (by
      show 8 ≤ (a - (x1.rsp - 8)).toNat
      rw [hx1sp]; exact handler_push_other lo x.rsp a hlo ha), hm1]
  have hrbp : x2.reg .rbp = x.reg .rbp := by
    show x2.regs 5 = x.regs 5
    rw [hregs2 5 (by decide), hkeep 5 (by simp [CalleeSaved])]
  have hrax : x2.reg .rax = x.reg .rax := by
    show x2.regs 0 = x.regs 0
    rw [hregs2 0 (by decide), hkeep 0 (by simp)]
  have hexec : execItems ctx (items ++ [Item.call (.handler n)]) x = .ok x2 := by
    have happ : execItems ctx (items ++ [Item.call (.handler n)]) x =
        (execItems ctx items x >>= execItems ctx [Item.call (.handler n)]) := by
      simp only [execItems, List.foldlM_append]; rfl
    rw [happ, he1, ex_bind_ok', X86.execItems_cons]; rfl
  have hA : Handler.ArgsIn ρ mode.pe x2 x2 args := by
    refine ⟨fun i h1 h2 => ?_, fun h4 hpe => absurd hreg (by rw [hpe]; simp [handlerRegs]; omega)⟩
    have hv : ∀ b, Handler.argVal ρ x2 b = Handler.argVal ρ x b := by
      intro b; cases b <;> simp [Handler.argVal, hrbp, hrax]
    rw [hv, hargs i h1 h2]
    suffices hs : x2.regs ((handlerRegs mode.pe)[i]).idx = x1.regs ((handlerRegs mode.pe)[i]).idx by
      show some (x1.regs _) = some (x2.regs _); rw [hs]
    apply hregs2
    have hm : (handlerRegs mode.pe)[i] ∈ X86.argRegs := Handler.mem_handlerRegs (List.getElem_mem h2)
    generalize (handlerRegs mode.pe)[i] = r at hm ⊢
    simp only [X86.argRegs, List.mem_cons, List.not_mem_nil, or_false] at hm
    rcases hm with rfl | rfl | rfl | rfl | rfl | rfl <;> decide
  have hat : Handler.AtHandler ctx h x2 := ⟨n, hn, by simp [x2, State.jump]⟩
  have hsaved : ∀ i, Saved mode.pe i → x2.regs i = x.regs i := by
    intro i hi
    have hs' := hs
    rw [Handler.setupItems_regs hreg] at hs'
    rw [hregs2 i (by rcases hi with (rfl | rfl | rfl | rfl | rfl | rfl) | ⟨-, rfl | rfl⟩ <;> decide),
      handler_setup_regs ctx mode args _ items x x1 hs' he1 i (by
        intro r hr
        cases hpe : mode.pe <;> rw [hpe] at hr <;>
          simp only [handlerRegs, X86.argRegs, Bool.false_eq_true, ↓reduceIte, List.mem_cons,
            List.not_mem_nil, or_false] at hr <;>
          rcases hi with (rfl | rfl | rfl | rfl | rfl | rfl) | ⟨hp, rfl | rfl⟩ <;>
          (try simp only [hpe, Bool.false_eq_true] at hp) <;>
          rcases hr with rfl | rfl | rfl | rfl | rfl | rfl <;> decide)]
  have hret : x2.mem.read64 x2.rsp = next := by
    have e : x2.rsp = x1.rsp - 8 := by rw [hrsp2, hx1sp]
    rw [e]
    exact CallLemmas.read64_write_self _ _ _
  refine ⟨x2, hexec, hat, hA, hrsp2, hsaved, hmem2, ?_⟩
  rw [hret]
  show x1.rip + _ = _
  rw [hrip1, BitVec.add_assoc, ← BitVec.ofNat_add]
  simp

/-! ### Fetching the setup and the call -/

/-- A setup item (either frame form; `r` a handler argument register): canonical everywhere,
falling through, memory kept. -/
theorem handler_argItem_ok (ctx : Ctx) {mode : Ryo.Obj.Mode} {r : X86.Reg} (hr : r.usable = true)
    {a : R.Arg} {it : Item} (h : Handler.argItem mode r a = some it) :
    (∀ p, it.Canonical p) ∧ it.FallsThrough ctx ∧ it.MemKept ctx := by
  have gen : ∀ it : Item, (∀ b e, it ≠ .tableEntry b e) → (∀ p, it.wf p = true) →
      (∀ s s', it.exec ctx s = .ok s' → s'.rip = s.rip + BitVec.ofNat 64 it.size ∧
        s'.mem = s.mem) →
      (∀ p, it.Canonical p) ∧ it.FallsThrough ctx ∧ it.MemKept ctx :=
    fun it ht hw he => ⟨fun p => ⟨ht, .inl (hw _)⟩, fun s s' h => (he s s' h).1,
      fun s s' h => (he s s' h).2⟩
  cases a with
  | fp =>
    simp only [Handler.argItem, Option.some.injEq] at h; subst h
    exact vt_fpItem_ok ctx mode hr
  | exception =>
    simp only [Handler.argItem, Option.some.injEq] at h; subst h
    exact gen _ (fun _ _ h => nomatch h) (fun _ => rfl) fun s s' he => by
      cases Switch.except_ok_inj he; exact ⟨rfl, rfl⟩
  | imm v =>
    simp only [Handler.argItem, Option.some.injEq] at h; subst h
    refine gen _ (fun _ _ h => nomatch h) (fun _ => rfl) fun s s' he => ?_
    simp only [Item.exec] at he
    split at he
    · cases Switch.except_ok_inj he; exact ⟨rfl, rfl⟩
    · cases Switch.except_ok_inj he; exact ⟨rfl, rfl⟩
  | const _ | data _ | sym _ | ro _ =>
    simp only [Handler.argItem, Handler.argRef, Option.map_some, Option.some.injEq] at h; subst h
    exact gen _ (fun _ _ h => nomatch h) (fun _ => rfl) fun s s' he => by
      cases Switch.except_ok_inj he; exact ⟨rfl, rfl⟩

theorem handler_mapM_mem {α β : Type} {f : α → Option β} :
    ∀ {l : List α} {bs : List β}, l.mapM f = some bs → ∀ b ∈ bs, ∃ a ∈ l, f a = some b
  | [], bs, h, b, hb => by simp at h; subst h; cases hb
  | a :: l, bs, h, b, hb => by
    simp only [List.mapM_cons, bind, Option.bind] at h
    cases ha : f a with
    | none => simp [ha] at h
    | some b0 =>
      simp only [ha] at h
      cases hl : l.mapM f with
      | none => simp [hl] at h
      | some bs' =>
        simp only [hl, pure, Option.some.injEq] at h
        subst h
        rcases List.mem_cons.mp hb with rfl | hb
        · exact ⟨a, by simp, ha⟩
        · obtain ⟨a', ha', hf⟩ := handler_mapM_mem hl b hb
          exact ⟨a', by simp [ha'], hf⟩

theorem handler_setup_ok (ctx : Ctx) {mode : Ryo.Obj.Mode}
    {args : List R.Arg} {items : List Item} (hs : Handler.setupItems mode args = some items)
    (hreg : args.length ≤ (handlerRegs mode.pe).length) :
    ∀ it ∈ items, (∀ p, it.Canonical p) ∧ it.FallsThrough ctx ∧ it.MemKept ctx := by
  intro it hit
  rw [Handler.setupItems_regs hreg] at hs
  obtain ⟨⟨a, r⟩, hmem, hf⟩ := handler_mapM_mem hs it hit
  exact handler_argItem_ok ctx (vt_handlerRegs _ r (List.of_mem_zip hmem).2).1 hf

theorem handler_canon_of : ∀ {l : List Item} {pos : Nat}, (∀ i ∈ l, ∀ p, i.Canonical p) →
    Canon l pos
  | [], _, _ => trivial
  | i :: l, pos, h => ⟨h i (by simp) pos, handler_canon_of fun j hj => h j (by simp [hj])⟩

theorem handler_call_canonical (n p : Nat) : (Item.call (.handler n)).Canonical p := by
  unfold Item.Canonical
  exact ⟨fun _ _ h => (nomatch h), Or.inl rfl⟩

/-- The setup and the call, fetched from memory at `p`. -/
theorem handler_call_steps {ctx : Ctx} {mode : Ryo.Obj.Mode}
    {args : List R.Arg} {items : List Item} (hs : Handler.setupItems mode args = some items)
    (hreg : args.length ≤ (handlerRegs mode.pe).length) {n p : Nat} {x x2 : X86.State} (hc : CodeAt ctx x.mem (items ++ [Item.call (.handler n)]) p)
    (hrip : x.rip = addrAt ctx p)
    (he : execItems ctx (items ++ [Item.call (.handler n)]) x = .ok x2) : Steps ctx x x2 := by
  have hok := handler_setup_ok ctx hs hreg
  have hcan : Canon (items ++ [Item.call (.handler n)]) p :=
    handler_canon_of fun i hi => by
      rcases List.mem_append.mp hi with hi | hi
      · exact (hok i hi).1
      · simp only [List.mem_singleton] at hi; subst hi; exact handler_call_canonical n
  exact steps_of_run_last (S := InCode ctx (items ++ [Item.call (.handler n)]) p) hcan hc hrip
    (fun _ h => h) (fetchRun_of_forall (fun i hi => (hok i hi).2) x) he

/-- The setup with PE's stack argument and the call, fetched from memory at `p`: the store
(`HandlerStackArg.fetchRun_stImm`) keeps the code when it is off the stack argument (`hS`). -/
theorem handler_call_steps5 {ctx : Ctx} {mode : Ryo.Obj.Mode}
    (hpe : mode.pe = true) {ρ : R.Addrs} (hl : Handler.Linked ctx ρ)
    {a0 a1 a2 a3 a4 : R.Arg} {items : List Item}
    (hs : Handler.setupItems mode [a0, a1, a2, a3, a4] = some items) {n p : Nat}
    {x x2 : X86.State} (hc : CodeAt ctx x.mem (items ++ [Item.call (.handler n)]) p)
    (hrip : x.rip = addrAt ctx p)
    (hS : ∀ a, InCode ctx (items ++ [Item.call (.handler n)]) p a →
      ¬ HandlerStackArg.InStackArg x.rsp a)
    (he : execItems ctx (items ++ [Item.call (.handler n)]) x = .ok x2) : Steps ctx x x2 := by
  obtain ⟨rItems, it, rfl, hs4, h4⟩ := HandlerStackArg.setupItems_pe5 hpe hs
  obtain ⟨v, -, -, rfl⟩ := HandlerStackArg.stackItem_some h4
  have hle : ([a0, a1, a2, a3] : List R.Arg).length ≤ (handlerRegs mode.pe).length := by
    simp [handlerRegs, hpe]
  have hok := handler_setup_ok ctx hs4 hle
  have hcan : Canon ((rItems ++ [Item.stImm .d M.stackArg (v.setWidth 32)]) ++
      [Item.call (.handler n)]) p :=
    handler_canon_of fun i hi => by
      rcases List.mem_append.mp hi with hi | hi
      · rcases List.mem_append.mp hi with hi | hi
        · exact (hok i hi).1
        · simp only [List.mem_singleton] at hi; subst hi
          exact HandlerStackArg.stImm_canonical _
      · simp only [List.mem_singleton] at hi; subst hi; exact handler_call_canonical n
  refine steps_of_run_last (S := InCode ctx ((rItems ++
      [Item.stImm .d M.stackArg (v.setWidth 32)]) ++ [Item.call (.handler n)]) p) hcan hc hrip
    (fun _ h => h) ?_ he
  refine HandlerStackArg.fetchRun_append_single
    (fetchRun_of_forall (fun i hi => (hok i hi).2) x) fun y hy => ?_
  refine HandlerStackArg.fetchRun_stImm _ y fun a ha => ?_
  obtain ⟨x1, he1, -, -, -, hr1, -⟩ := Handler.exec_setup ctx ρ mode _ rItems x hs4 hle hl
  rw [he1] at hy
  have hsp : y.rsp = x.rsp := by
    rw [← Switch.except_ok_inj hy]
    exact hr1 4 (by
      intro r hr
      simp only [X86.argRegs, List.mem_cons, List.not_mem_nil, or_false] at hr
      rcases hr with rfl | rfl | rfl | rfl | rfl | rfl <;> decide)
  rw [hsp]
  exact hS a ha

/-! ### The setup without a frame pointer -/

/-- What `steps_of_run_last_fb` needs of a setup item without a frame pointer: its memory form
canonical, `rbp` only a memory base, `rsp` kept, falling through with memory kept. -/
structure VtItem (ctx : Ctx) (F : BitVec 32) (it : Item) : Prop where
  can : ∀ p, (FForm.item (some F) it).Canonical p
  rbp : it.RbpFree
  rsp : it.RspKept ctx
  ft : it.FallsThrough ctx
  mkept : it.MemKept ctx
  rip : it.RipFree ctx

theorem vt_argItem_sp (ctx : Ctx) (F : BitVec 32) {mode : Ryo.Obj.Mode}
    (hm : mode.framePointer = false) {r : X86.Reg} {a : R.Arg} {it : Item}
    (hr : r ∈ handlerRegs mode.pe) (h : Handler.argItem mode r a = some it) : VtItem ctx F it := by
  obtain ⟨hu, hrsp, hrbp⟩ := vt_handlerRegs mode.pe r hr
  obtain ⟨-, hft, hmk⟩ := handler_argItem_ok ctx hu h
  have hne : (r != Reg.rbp) = true := bne_iff_ne.mpr hrbp
  cases a with
  | fp =>
    simp only [Handler.argItem, fpItem, hm, Bool.false_eq_true, ↓reduceIte,
      Option.some.injEq] at h
    subst h
    refine ⟨fun p => ⟨fun b e he => (by cases he), .inr ⟨.leaM r (M.frame 0), F, ?_, rfl⟩⟩, ?_, ?_,
      hft, hmk, (by intro s a; first | rfl | (simp only [Item.exec]; split <;> rfl))⟩
    · show (r.usable && Item.memWf (M.frame 0)) = true
      rw [hu]; rfl
    · show (r.usable && Item.memWf (M.frame 0)) = true
      rw [hu]; rfl
    · intro y y' he
      cases Switch.except_ok_inj he
      simp [X86.State.rsp, X86.State.reg, X86.State.setReg, X86.State.jump, hrsp] <;> (try (intro h; exact absurd h hrsp))
  | exception =>
    simp only [Handler.argItem, Option.some.injEq] at h
    subst h
    refine ⟨fun p => ⟨fun b e he => (by cases he), .inl rfl⟩, ?_, ?_, hft, hmk, (by intro s a; first | rfl | (simp only [Item.exec]; split <;> rfl))⟩
    · show (r != Reg.rbp && Reg.rax != Reg.rbp) = true
      rw [hne]; rfl
    · intro y y' he
      cases Switch.except_ok_inj he
      simp [X86.State.rsp, X86.State.reg, X86.State.setReg, X86.State.jump, hrsp] <;> (try (intro h; exact absurd h hrsp))
  | imm v =>
    simp only [Handler.argItem, Option.some.injEq] at h
    subst h
    refine ⟨fun p => ⟨fun b e he => (by cases he), .inl rfl⟩, hne, ?_, hft, hmk, (by intro s a; first | rfl | (simp only [Item.exec]; split <;> rfl))⟩
    intro y y' he
    simp only [Item.exec] at he
    split at he
    · cases Switch.except_ok_inj he
      simp [X86.State.rsp, X86.State.reg, X86.State.setReg, X86.State.setFlags, X86.State.jump, hrsp] <;> (try (intro h; exact absurd h hrsp))
    · cases Switch.except_ok_inj he
      simp [X86.State.rsp, X86.State.reg, X86.State.setReg, X86.State.jump, hrsp] <;> (try (intro h; exact absurd h hrsp))
  | const _ | data _ | sym _ | ro _ =>
    simp only [Handler.argItem, Handler.argRef, Option.map_some, Option.some.injEq] at h
    subst h
    refine ⟨fun p => ⟨fun b e he => (by cases he), .inl rfl⟩, hne, ?_, hft, hmk, (by intro s a; first | rfl | (simp only [Item.exec]; split <;> rfl))⟩
    intro y y' he
    cases Switch.except_ok_inj he
    simp [X86.State.rsp, X86.State.reg, X86.State.setReg, X86.State.jump, hrsp] <;> (try (intro h; exact absurd h hrsp))

theorem hdl_setup_sp (ctx : Ctx) (F : BitVec 32) {mode : Ryo.Obj.Mode}
    (hm : mode.framePointer = false) {args : List R.Arg} {items : List Item}
    (hs : Handler.setupItems mode args = some items)
    (hreg : args.length ≤ (handlerRegs mode.pe).length) : ∀ it ∈ items, VtItem ctx F it := by
  intro it hit
  rw [Handler.setupItems_regs hreg] at hs
  obtain ⟨⟨a, r⟩, hmem, hf⟩ := handler_mapM_mem hs it hit
  exact vt_argItem_sp ctx F hm (List.of_mem_zip hmem).2 hf

theorem hdl_link_length (addr : BitVec 64) (addrOf : RefAddr) :
    ∀ (relocs : List X86.Reloc) (code : List UInt8), (link addr addrOf code relocs).length = code.length
  | [], _ => rfl
  | r :: rs, code => by
    simp only [link, List.foldl_cons] at *
    have := hdl_link_length addr addrOf rs
    simp only [link] at this
    rw [this]; simp

theorem hdl_linkedAt_length (ctx : Ctx) (i : Item) (pos : Nat) :
    (i.linkedAt ctx pos).length = i.size := by
  unfold Item.linkedAt
  simp only
  rw [hdl_link_length, encode_len]

/-- The addresses of items decoded from a linked cursor are code addresses (`ctr_inCode_dec`). -/
theorem hdl_inCode_dec {ctx : Ctx} {m : Mem} {c : Cursor} {rs : Array Reloc} (hk : LinkOk ctx m c rs) :
    ∀ {p q : Nat} {items : List Item}, Dec c p items q → Boundary rs p →
      ∀ a, InCode ctx items p a → ∃ j, j < c.code.size ∧ a = addrAt ctx j := by
  intro p q items hd
  induction hd with
  | nil => intro _ a h; exact absurd h id
  | @cons p n q i is hdi _ ih =>
    intro hb a ha
    obtain ⟨-, hsz, hle, hb'⟩ := decodeItem_itemAt (c := atPos c p) hk.fields hk.sorted hk.loaded
      hk.small hk.fp hb hdi
    rcases ha with ⟨j, hj, rfl⟩ | ha
    · rw [hdl_linkedAt_length, hsz] at hj
      exact ⟨p + j, by simp at hle; omega, addrAt_add' ctx p j⟩
    · rw [hsz] at ha; exact ih hb' a ha

section Insn

variable {S : Setup} {code : ByteArray} {relocs : Array Reloc} {rodata : ByteArray}
  {callSites : Array CallSite} {dropped : Array DroppedStore} {scopes : Array R.Scope}
  {mode : Ryo.Obj.Mode}

/-! ### `FrameInv` across the environment (as `DSWork/Counter.lean`'s `ctr_frameInv`) -/

/-- What keeping `FrameInv` across an environment step needs (`hdl_apart`). -/
structure HdlApart (S : Setup) : Prop where
  window : ∀ s x, FrameInv S s x → ∀ o : Int, -(S.F : Int) ≤ o → o < S.K → ¬ S.Owned (fpAddr x o)
  allocs : ∀ s x, FrameInv S s x → ∀ a, Call.InAlloc s.world a →
    ¬ S.Owned a ∧ ¬ InStack S.lo x.rsp a
  relocs : ∀ r ∈ S.rs.toList, r.pos + 4 ≤ S.body.code.size

theorem hdl_apart (_hD : Decodes S code relocs rodata callSites dropped scopes mode)
    (H : Hyps S) : HdlApart S :=
  ⟨fun s x hf o h1 h2 => by rw [hf.fpAddr_eq]; exact H.envApart.window o h1 h2,
    H.envApart.allocs, H.relocsIn⟩

theorem hdl_add_sub_left (x y : BitVec 64) : x + y - x = y := by bv_omega


theorem hdl_base_setWidth (ctx : Ctx) (t : BitVec 32) :
    ctx.base + t.setWidth 64 = addrAt ctx t.toNat := by
  unfold addrAt; congr 1
  apply BitVec.eq_of_toNat_eq
  simp only [BitVec.toNat_setWidth, BitVec.toNat_ofNat]

/-- The numbers behind a frame without `rsp` (`FrameCore`): `rbp = fp`, the entry `rsp = fp + 8`. -/
theorem hdl_nums_core (H : Hyps S) {s : R.RState} {x : X86.State} (hf : FrameCore S s x) :
    (x.reg .rbp).toNat = s.fp ∧ S.x0.rsp.toNat = s.fp + 8 ∧
      s.fp + 16 ≤ 2 ^ 64 ∧ S.F ≤ s.fp ∧ (S.K : Int) ≤ 2 ^ 31 ∧ 16 ≤ S.K := by
  have hK := H.argSizeK
  have hKl := H.frameBounds.K_le
  have hwin := hf.win
  have hfp := hf.fpF
  have hb := hf.rrel.rbp
  have hlt : s.fp < 2 ^ 64 := by omega
  have hrb : (x.reg .rbp).toNat = s.fp := by rw [hb, BitVec.toNat_ofNat, Nat.mod_eq_of_lt hlt]
  refine ⟨hrb, ?_, by omega, hfp, hKl, by omega⟩
  have e : S.x0.rsp = x.reg .rbp + 8 := by have := hf.frame.rbp; bv_omega
  rw [e, BitVec.toNat_add, hrb]; simp; omega

/-- The numbers behind a boundary's frame: `rbp = fp`, `rsp = fp - F`, the entry `rsp = fp + 8`. -/
theorem hdl_nums (H : Hyps S) {s : R.RState} {x : X86.State} (hf : FrameInv S s x) :
    (x.reg .rbp).toNat = s.fp ∧ x.rsp.toNat = s.fp - S.F ∧ S.x0.rsp.toNat = s.fp + 8 ∧
      s.fp + 16 ≤ 2 ^ 64 ∧ S.F ≤ s.fp ∧ (S.K : Int) ≤ 2 ^ 31 ∧ 16 ≤ S.K := by
  obtain ⟨hrb, h0, h16, hfp, hKl, hK16⟩ := hdl_nums_core H hf.toCore
  refine ⟨hrb, ?_, h0, h16, hfp, hKl, hK16⟩
  rw [hf.rsp, BitVec.toNat_sub, hrb, BitVec.toNat_ofNat]
  have : S.F < 2 ^ 64 := by omega
  rw [Nat.mod_eq_of_lt this]; omega

/-- At a boundary `rsp` is the frame's bottom (the core lemmas' `hle`). -/
theorem hdl_rsp_bottom (H : Hyps S) {s : R.RState} {x : X86.State} (hf : FrameInv S s x) :
    x.rsp.toNat ≤ s.fp - S.F := by
  obtain ⟨-, h2, -⟩ := hdl_nums H hf; omega

theorem hdl_rsp_le (H : Hyps S) {s : R.RState} {x : X86.State} (hf : FrameInv S s x) :
    x.rsp.toNat ≤ S.x0.rsp.toNat := by
  obtain ⟨-, h2, h3, -⟩ := hdl_nums H hf; omega

theorem hdl_inStack_lift (H : Hyps S) {s : R.RState} {x : X86.State} (hf : FrameInv S s x)
    {a : BitVec 64} (h : ¬ InStack S.lo S.x0.rsp a) : ¬ InStack S.lo x.rsp a := by
  have := hdl_rsp_le H hf
  intro ⟨h1, h2⟩; exact h ⟨h1, by omega⟩

/-- `hdl_inStack_lift` with `rsp` at or below the frame's bottom (`hle`; PE's pad region too). -/
theorem hdl_inStack_lift_core (H : Hyps S) {s : R.RState} {x : X86.State} (hf : FrameCore S s x)
    (hle : x.rsp.toNat ≤ s.fp - S.F) {a : BitVec 64} (h : ¬ InStack S.lo S.x0.rsp a) :
    ¬ InStack S.lo x.rsp a := by
  obtain ⟨-, h0, -⟩ := hdl_nums_core H hf
  intro ⟨h1, h2⟩; exact h ⟨h1, by omega⟩

/-- The frame window is apart from what the handler call may write (`S.Owned`, the stack below
`rsp`, with `rsp` at or below the frame's bottom). -/
theorem hdl_window_apart_core (H : Hyps S) {s : R.RState} {x : X86.State}
    (hf : FrameCore S s x) (hle : x.rsp.toNat ≤ s.fp - S.F) {o : Int} (h1 : -(S.F : Int) ≤ o)
    (h2 : o < S.K) :
    ¬ S.Owned (fpAddr x o) ∧ ¬ InStack S.lo x.rsp (fpAddr x o) := by
  refine ⟨by rw [hf.fpAddr_eq]; exact H.envApart.window o h1 h2, fun ⟨_, hs⟩ => ?_⟩
  obtain ⟨hrb, -, hw, hF, hKl, -⟩ := hdl_nums_core H hf
  have hwin := hf.win
  simp only [fpAddr, BitVec.toNat_add, hrb, BitVec.toNat_ofInt] at hs
  omega

/-- The frame window is apart from what the handler call may write (`S.Owned`, the stack below
`rsp`). -/
theorem hdl_window_apart (H : Hyps S) (_HC : HdlApart S) {s : R.RState} {x : X86.State}
    (hf : FrameInv S s x) {o : Int} (h1 : -(S.F : Int) ≤ o) (h2 : o < S.K) :
    ¬ S.Owned (fpAddr x o) ∧ ¬ InStack S.lo x.rsp (fpAddr x o) :=
  hdl_window_apart_core H hf.toCore (hdl_rsp_bottom H hf) h1 h2

/-- `m` agrees with `x`'s memory outside what the handler call may write (`S.Owned`, and the
stack in `[S.lo, rsp)`). -/
abbrev hdl_Keeps (S : Setup) (x : X86.State) (m : Mem) : Prop :=
  ∀ a, ¬ S.Owned a → ¬ InStack S.lo x.rsp a → m a = x.mem a

theorem hdl_linkOk_core (H : Hyps S) {s : R.RState} {x : X86.State}
    (hf : FrameCore S s x) (hle : x.rsp.toNat ≤ s.fp - S.F) {m : Mem} (hm : hdl_Keeps S x m) :
    LinkOkF S.ctx m S.body S.rs S.c.mode := by
  have hc : ∀ j, j < S.body.code.size → m (addrAt S.ctx j) = x.mem (addrAt S.ctx j) := by
    intro j hj
    obtain ⟨ho, hst, -⟩ := H.codeApart (addrAt S.ctx j) (.inl ⟨j, hj, rfl⟩)
    exact hm _ ho (hdl_inStack_lift_core H hf hle hst)
  obtain ⟨hfl, hso, ⟨hl1, hl2⟩, hsm, hfp⟩ := hf.code
  refine ⟨hfl, hso, ⟨fun j hj hr => ?_, fun r hr k hk => ?_⟩, hsm, hfp⟩
  · rw [hc j hj]; exact hl1 j hj hr
  · rw [hc _ (by have := H.relocsIn r hr; omega)]; exact hl2 r hr k hk

theorem hdl_linkOk (H : Hyps S) (_HC : HdlApart S) {s : R.RState} {x : X86.State}
    (hf : FrameInv S s x) {m : Mem} (hm : hdl_Keeps S x m) :
    LinkOkF S.ctx m S.body S.rs S.c.mode :=
  hdl_linkOk_core H hf.toCore (hdl_rsp_bottom H hf) hm

theorem hdl_roLoaded_core (H : Hyps S) {s : R.RState} {x : X86.State}
    (hf : FrameCore S s x) (hle : x.rsp.toNat ≤ s.fp - S.F) {m : Mem} (hm : hdl_Keeps S x m) :
    RoLoaded S.ctx m S.ro := by
  obtain ⟨base, h1, h2⟩ := hf.ro
  refine ⟨base, h1, fun j hj => ?_⟩
  obtain ⟨ho, hst, -⟩ := H.codeApart (base + BitVec.ofNat 64 j) (.inr ⟨j, hj, (h1 j).symm⟩)
  rw [hm _ ho (hdl_inStack_lift_core H hf hle hst)]; exact h2 j hj

theorem hdl_roLoaded (H : Hyps S) {s : R.RState} {x : X86.State}
    (hf : FrameInv S s x) {m : Mem} (hm : hdl_Keeps S x m) : RoLoaded S.ctx m S.ro :=
  hdl_roLoaded_core H hf.toCore (hdl_rsp_bottom H hf) hm

theorem hdl_read64_core (H : Hyps S) {s : R.RState} {x : X86.State}
    (hf : FrameCore S s x) (hle : x.rsp.toNat ≤ s.fp - S.F) {m : Mem} (hm : hdl_Keeps S x m)
    {o : Int} (h1 : -(S.F : Int) ≤ o) (h2 : o + 8 ≤ S.K) :
    m.read64 (fpAddr x o) = x.mem.read64 (fpAddr x o) := by
  unfold Mem.read64; congr 1
  apply readNat_congr
  intro i hi
  rw [← fpAddr_add]
  obtain ⟨a1, a2⟩ := hdl_window_apart_core H hf hle (o := o + i) (by omega) (by omega)
  exact hm _ a1 a2

theorem hdl_read64 (H : Hyps S) (_HC : HdlApart S) {s : R.RState} {x : X86.State}
    (hf : FrameInv S s x) {m : Mem} (hm : hdl_Keeps S x m) {o : Int}
    (h1 : -(S.F : Int) ≤ o) (h2 : o + 8 ≤ S.K) : m.read64 (fpAddr x o) = x.mem.read64 (fpAddr x o) :=
  hdl_read64_core H hf.toCore (hdl_rsp_bottom H hf) hm h1 h2

/-- A frame byte `opSem` can read and that is initialized is apart from the handler call's
writes (`S.Owned`, the stack below `rsp`), given `rsp` at or below the frame's bottom (`hle`) and
no live allocation owned or below `rsp` (`hal`). -/
theorem hdl_byte_apart_core (H : Hyps S) {s : R.RState} {x : X86.State}
    (hf : FrameCore S s x) (hle : x.rsp.toNat ≤ s.fp - S.F)
    (hal : ∀ a, Call.InAlloc s.world a → ¬ S.Owned a ∧ ¬ InStack S.lo x.rsp a)
    {o : Int} {b : AbstractByte} (hb : s.st.byteAt o = .ok b) (hu : b ≠ .uninit) :
    ¬ S.Owned (fpAddr x o) ∧ ¬ InStack S.lo x.rsp (fpAddr x o) := by
  unfold OpSem.State.byteAt at hb
  split at hb
  · rename_i hn
    have hb' : s.st.frame o = b := by simpa [pure, Except.pure] using hb
    obtain ⟨i1, i2⟩ := hf.sep.init o hn (by rw [hb']; exact hu)
    exact hdl_window_apart_core H hf hle i1 i2
  · rename_i e he
    split at hb
    · rename_i a hg
      split at hb
      · cases hb
      · rename_i hlive
        split at hb
        · rename_i b' hd
          have hmem : e ∈ s.st.escaped := List.mem_of_find?_eq_some he
          have hin := List.find?_some he
          simp only [decide_eq_true_eq] at hin
          have hlay := hf.rrel.rel.layout e hmem a hg
          have hn : ((o - e.off).toNat : Int) = o - e.off := Int.toNat_of_nonneg (by omega)
          have hlt : (o - e.off).toNat < a.data.size := by
            rcases Array.getElem?_eq_some_iff.1 hd with ⟨h, -⟩; exact h
          have hsp := hf.sep.space e.id a hg (by simpa using hlive)
          have haddr : fpAddr x o = BitVec.ofNat 64 a.addr + BitVec.ofNat 64 (o - e.off).toNat := by
            rw [hlay, ← fpAddr_add, hn]; congr 1; omega
          refine hal _ ⟨e.id, a, hg, by simpa using hlive, ?_⟩
          rw [haddr, hdl_add_sub_left, BitVec.toNat_ofNat]
          simp only [Allocation.size] at *
          omega
        · cases hb
    · cases hb

/-- A frame byte `opSem` can read and that is initialized is apart from the handler call's
writes (`S.Owned`, the stack below `rsp`). -/
theorem hdl_byte_apart (H : Hyps S) (HC : HdlApart S) {s : R.RState} {x : X86.State}
    (hf : FrameInv S s x) {o : Int} {b : AbstractByte} (hb : s.st.byteAt o = .ok b)
    (hu : b ≠ .uninit) :
    ¬ S.Owned (fpAddr x o) ∧ ¬ InStack S.lo x.rsp (fpAddr x o) :=
  hdl_byte_apart_core H hf.toCore (hdl_rsp_bottom H hf) (HC.allocs s x hf) hb hu

/-- `FrameCore` survives a state that agrees with `x` (`Counter.Agree`), given `rsp` at or below
the frame's bottom (`hle`) and no live allocation owned or below `rsp` (`hal`): in the body
(`hdl_frameInv`) and in PE's pad region. -/
theorem hdl_frameCore (H : Hyps S) {s : R.RState} {x y : X86.State}
    (hf : FrameCore S s x) (hle : x.rsp.toNat ≤ s.fp - S.F)
    (hal : ∀ a, Call.InAlloc s.world a → ¬ S.Owned a ∧ ¬ InStack S.lo x.rsp a)
    (hag : Counter.Agree S.Owned S.lo x y)
    (hsv : ∀ i, Saved S.c.mode.pe i → y.regs i = x.regs i) :
    FrameCore S s y := by
  have hrbp : y.reg .rbp = x.reg .rbp := hag.2.1 5 (Or.inr (Or.inl rfl))
  have hfp : ∀ o, fpAddr y o = fpAddr x o := fun o => by simp [fpAddr, hrbp]
  have hm : hdl_Keeps S x y.mem := hag.2.2
  obtain ⟨hrb, -, hw, hF, hKl, hK16⟩ := hdl_nums_core H hf
  refine ⟨⟨⟨fun o h1 h2 b hb => ?_, fun e he a h => ?_, fun p hp => ?_⟩, hrbp.trans hf.rrel.rbp,
    hf.rrel.wf⟩, fun id a hg hl i hi => ?_, hf.sep.congr hrbp, hf.win, hf.fpF,
    hdl_linkOk_core H hf hle hm, hdl_roLoaded_core H hf hle hm, ?_, hf.slots, hf.esc⟩
  · have hr := hf.rrel.rel.frame o h1 h2 b hb
    rw [hfp]
    cases b with
    | uninit => trivial
    | init v p =>
      obtain ⟨a1, a2⟩ := hdl_byte_apart_core H hf hle hal hb (by simp)
      rw [hm _ a1 a2]; exact hr
  · rw [hfp]; exact hf.rrel.rel.layout e he a h
  · rw [hfp]; exact hf.rrel.rel.zeroSized p hp
  · have hr := hf.mem id a hg hl i hi
    have hsp := hf.sep.space id a hg hl
    obtain ⟨a1, a2⟩ := hal (BitVec.ofNat 64 (a.addr + i)) ⟨id, a, hg, hl, by
      rw [BitVec.ofNat_add, hdl_add_sub_left, BitVec.toNat_ofNat]
      simp only [Allocation.size] at *
      omega⟩
    rw [hm _ a1 a2]; exact hr
  · obtain ⟨f1, f2, f3, f5⟩ := hf.frame
    have e8 : x.reg .rbp + 8 = fpAddr x 8 := rfl
    have e0 : x.reg .rbp = fpAddr x 0 := by simp [fpAddr]
    refine ⟨by rw [hrbp]; exact f1, ?_, ?_, fun i hi h5 => by
      rw [hsv i hi]; exact f5 i hi h5⟩
    · rw [hrbp, e8, hdl_read64_core H hf hle hm (by omega) (by omega), ← e8]; exact f2
    · intro hfp3; rw [hrbp, e0, hdl_read64_core H hf hle hm (by omega) (by omega), ← e0]
      exact f3 hfp3

/-- `FrameInv` survives a state that agrees with `x` (`Counter.Agree`), at an instruction past
the leading `arg`s. -/
theorem hdl_frameInv (H : Hyps S) (HC : HdlApart S) {s : R.RState} {x y : X86.State}
    (hf : FrameInv S s x) (hag : Counter.Agree S.Owned S.lo x y)
    (hsv : ∀ i, Saved S.c.mode.pe i → y.regs i = x.regs i) (ha : ¬ LeadArg S s.pc) :
    FrameInv S s y := by
  have hrbp : y.reg .rbp = x.reg .rbp := hag.2.1 5 (Or.inr (Or.inl rfl))
  exact FrameInv.ofCore
    (hdl_frameCore H hf.toCore (hdl_rsp_bottom H hf) (HC.allocs s x hf) hag hsv)
    (by rw [hag.1, hrbp]; exact hf.rsp) (by rw [hag.1]; exact hf.room) (fun h => absurd h ha)


theorem handler_dense_op {fr : Vm.Frame} {c c' : Cursor} {q : Proto}
    (h : (denseSwitch fr).run c = .ok (some q, c')) : ∃ w, q.op = denseOp w := by
  unfold denseSwitch at h
  obtain ⟨x, c1, h1, h2⟩ := bind_ok h
  obtain ⟨rfl, rfl⟩ := get_run h1
  split at h2
  · rename_i w _ _ _ _ _
    obtain ⟨u, c2, h3, h⟩ := bind_ok h2
    obtain ⟨ts, c3, h4, h⟩ := bind_ok h
    split at h
    · obtain ⟨e, -⟩ := pure_ok h
      cases e; exact ⟨w, rfl⟩
    · exact (err_ok h).elim
  · obtain ⟨e, -⟩ := pure_ok h2; cases e

set_option maxRecDepth 100000 in
theorem handler_thenSeq_resume {nn hat : Nat} {c c' : Cursor} {t : R.Then Nat}
    {sites : List (Nat × Nat)} (h : (thenSeq .resume nn hat).run c = .ok ((t, sites), c')) :
    t = .trap ∧ sites = [(hat, 5)] := by
  unfold thenSeq at h
  simp only [Shapes.resume_shape] at h
  obtain ⟨u, c1, -, h⟩ := bind_ok h
  obtain ⟨he, -⟩ := pure_ok h
  simp only [Prod.mk.injEq] at he
  obtain ⟨rfl, rfl⟩ := he
  exact ⟨rfl, by simp only [show (Full.Opcode.resume == Full.Opcode.resume) = true from by decide,
    ↓reduceIte]⟩

set_option maxRecDepth 100000 in
/-- `resume`'s layout (one operand, the slot, after `fp` with `fpArg`) fits in the handler
argument registers: its calls never take PE's stack argument (`unpack` bounds the arguments to
the layout's `regs`). -/
theorem resume_regs_le (a b : Bool) :
    ((Full.Opcode.resume.layout a b).map (·.regs)).getD 0 ≤ (handlerRegs b).length := by
  cases a <;> cases b <;> decide

/-! ### The general handler call (not `resume`) -/

set_option maxRecDepth 100000 in
theorem hdl_arg_shape : Full.Opcode.arg.info.shape = .arg := by decide

theorem hdl_footprint {op : Full.Opcode} {ops : Operands} {st : OpSem.State} {ch : OpSem.Choice}
    {r : Control × OpSem.State} (h : opSem op ops st ch = .ok r) : ∃ fp, footprint op = some fp := by
  unfold opSem at h
  cases hp : prepare op ops with
  | error e => simp [hp, bind, Except.bind] at h
  | ok y =>
    obtain ⟨hi, fp, val⟩ := y
    exact ⟨fp, (prepare_ok hp).1⟩

theorem hdl_succ_next {pc pc' : Nat} {ctl : Control} (h : R.Then.succ .next pc ctl = some pc') :
    pc' = pc + 1 := by
  cases ctl with
  | next => exact (Option.some.inj h).symm
  | branch b =>
    have e : R.Then.succ (.next : R.Then Nat) pc (.branch b) = none := rfl
    rw [e] at h; cases h
  | index i =>
    have e : R.Then.succ (.next : R.Then Nat) pc (.index i) = none := rfl
    rw [e] at h; cases h

theorem hdl_succ_branch {neg : Bool} {j pc pc' : Nat} {ctl : Control}
    (h : R.Then.succ (.branch neg j) pc ctl = some pc') :
    ∃ b, ctl = .branch b ∧ (if (b != neg) = true then j else pc + 1) = pc' := by
  cases ctl with
  | branch b => exact ⟨b, rfl, Option.some.inj h⟩
  | next =>
    have e : R.Then.succ (.branch neg j) pc .next = none := rfl
    rw [e] at h; cases h
  | index i =>
    have e : R.Then.succ (.branch neg j) pc (.index i) = none := rfl
    rw [e] at h; cases h

theorem hdl_succ_table {ts : List Nat} {pc pc' : Nat} {ctl : Control}
    (h : R.Then.succ (.table ts) pc ctl = some pc') : ∃ i, ctl = .index i ∧ ts[i]? = some pc' := by
  cases ctl with
  | index i => exact ⟨i, rfl, h⟩
  | next =>
    have e : R.Then.succ (.table ts) pc .next = none := rfl
    rw [e] at h; cases h
  | branch b =>
    have e : R.Then.succ (.table ts) pc (.branch b) = none := rfl
    rw [e] at h; cases h

theorem hdl_succ_trap {pc pc' : Nat} {ctl : Control}
    (h : R.Then.succ (.trap : R.Then Nat) pc ctl = some pc') : False := by
  have e : R.Then.succ (.trap : R.Then Nat) pc ctl = none := by cases ctl <;> rfl
  rw [e] at h; cases h

theorem hdl_testAl_straight (ctx : Ctx) :
    Item.testAl.FallsThrough ctx ∧ Item.testAl.MemKept ctx :=
  ⟨fun _ _ h => by cases Switch.except_ok_inj h; rfl,
    fun _ _ h => by cases Switch.except_ok_inj h; rfl⟩

theorem hdl_dec2 {c : Cursor} {p q : Nat} {i j : Item} (h : Dec c p [i, j] q) :
    ∃ n1 n2, decodeItem (atPos c p) = some (i, n1) ∧
      decodeItem (atPos c (p + n1)) = some (j, n2) ∧ q = p + n1 + n2 := by
  cases h with
  | cons h1 hr =>
    cases hr with
    | cons h2 hn => exact ⟨_, _, h1, h2, Dec.nil_eq hn⟩

/-- The switch's jump changes only `rax` and `rcx` of the general registers. -/
theorem hdl_switch_regs {ctx : Ctx} {tb : BitVec 32} {x y : X86.State}
    (h : execItems ctx (Switch.switchItems tb) x = .ok y) (i : Fin 16) (h0 : i ≠ 0) (h1 : i ≠ 1) :
    y.regs i = x.regs i := by
  simp only [Switch.switchItems] at h
  rw [X86.execItems_cons] at h
  obtain ⟨y1, e1, h⟩ := except_bind_ok h
  rw [X86.execItems_cons] at h
  obtain ⟨y2, e2, h⟩ := except_bind_ok h
  rw [X86.execItems_cons] at h
  obtain ⟨y3, e3, h⟩ := except_bind_ok h
  rw [X86.execItems_cons] at h
  obtain ⟨y4, e4, h⟩ := except_bind_ok h
  rw [X86.execItems_nil] at h
  cases Switch.except_ok_inj h
  cases Switch.except_ok_inj e4
  cases Switch.except_ok_inj e3
  cases Switch.except_ok_inj e2
  cases Switch.except_ok_inj e1
  simp [State.setReg, State.jump, State.setFlags, h0, h1]

/-- The next instruction is not a leading `arg` when this one isn't an `arg`. -/
theorem hdl_next_notLead (hD : Decodes S code relocs rodata callSites dropped scopes mode)
    {k p : Nat} {q : Proto} {c' : Cursor} {cache' : Cache}
    (hP : ProtoFacts S k p q c' cache') (hq : q.op ≠ .arg) : ¬ LeadArg S (k + 1) := by
  rintro ⟨hlt', ha⟩
  have hia : (q.op == Full.Opcode.arg) = false := by
    cases hb : (q.op == Full.Opcode.arg)
    · rfl
    · exact absurd (beq_iff_eq.1 hb) hq
  have h1 : S.args (k + 1) = false := by rw [hP.args, hia, Bool.and_false]
  have h2 := hD.argsSucc (k + 1) (by simpa using hlt')
  rw [h1] at h2
  simp [h2] at ha

/-- `FrameInv` survives a state with the same memory, `rbp`, `rsp` and saved registers, past the
leading `arg`s. -/
theorem hdl_frameInv_regs {s : R.RState} {x y : X86.State} (hf : FrameInv S s x)
    (hm : y.mem = x.mem) (hrbp : y.reg .rbp = x.reg .rbp) (hrsp : y.rsp = x.rsp)
    (hsv : ∀ i, Saved S.c.mode.pe i → y.regs i = x.regs i) (ha : ¬ LeadArg S s.pc) :
    FrameInv S s y := by
  obtain ⟨⟨hrel, hb, hwf⟩, hmem, hsep, hwin, hfpF, hsp, hroom, hcode, hro, -, hfr, hsl, hesc⟩ := hf
  obtain ⟨f1, f2, f3, f5⟩ := hfr
  exact ⟨⟨Inline.rel_congr hrel hrbp hm, hrbp.trans hb, hwf⟩, Shapes.memRel_congr hm hmem,
    hsep.congr hrbp, hwin, hfpF, by rw [hrsp, hrbp]; exact hsp, by rw [hrsp]; exact hroom,
    by rw [hm]; exact hcode, by rw [hm]; exact hro, fun h => absurd h ha,
    ⟨by rw [hrbp]; exact f1, by rw [hrbp, hm]; exact f2, fun hfp3 => by rw [hrbp, hm]; exact f3 hfp3,
      fun i hi h5 => by rw [hsv i hi]; exact f5 i hi h5⟩, hsl, hesc.of_not ha⟩

/-- A handler call's home bytes (`R.handlerHome`: PE's 32-byte home space, 40 with a stack
argument) fit in the frame: `shadowSize` covers them and `frameSizesCheck` bounds it by `F`
(`peStackArgCheck`); `32 ≤ F` on PE (`Hyps.peShadow`). -/
theorem hdl_home_le (H : Hyps S) {k : Nat} {h : Full.Opcode} {args : List R.Arg}
    {t : R.Then Nat} (hi : S.c.d.insns[k]? = some (.handler h args t)) :
    R.handlerHome S.c.mode.pe args.length ≤ S.F := by
  have hF : S.F = S.c.d.frameSize := rfl
  unfold R.handlerHome
  by_cases hpe : S.c.mode.pe = true
  · rw [if_pos hpe]
    by_cases h4 : args.length > 4
    · rw [if_pos h4]
      have hp := Discharge.PeStackArg.peStackArgCheck_of_frameSizes H.frameSizes
      unfold peStackArgCheck at hp
      have hs := of_decide_eq_true hp
      have h40 : S.c.d.shadowSize S.c.mode = 40 := by
        unfold R.Decoded.shadowSize
        split
        · next hn => simp [hpe] at hn
        · split
          · rfl
          · next hno =>
            exfalso
            apply hno
            exact Array.any_eq_true'.2 ⟨_, Array.mem_of_getElem? hi, by simp [h4]⟩
      omega
    · rw [if_neg h4]
      exact H.peShadow hpe
  · rw [if_neg hpe]
    exact Nat.zero_le _

/-- `R.clearHome` at `-F` with at most `F` bytes keeps `FrameCore`: the cleared bytes are `Uninit`,
which relates to any x86 byte (`CallLemmas.rel_writeFrame_in`, `ScopeMem.memRel_writeUninit`),
lie in the window (`island_sep_writeFrame`) and keep the slots (`ArgSlots.writeFrame_uninit`). -/
theorem hdl_frameCore_clear (H : Hyps S) {s : R.RState} {x : X86.State} {st'' : OpSem.State}
    {n : Nat} (hf : FrameCore S s x) (hn : R.handlerHome S.c.mode.pe n ≤ S.F)
    (hcl : R.clearHome S.c.mode.pe n (-(S.F : Int)) s.st = .ok st'') :
    FrameCore S { s with st := st'' } x := by
  have hFle : (S.F : Int) ≤ 2 ^ 31 := H.frameBounds.F_le
  obtain ⟨-, -, -, -, -, hK16⟩ := hdl_nums_core H hf
  rcases Shapes.clearHome_cases hcl with ⟨-, hw⟩ | ⟨-, rfl⟩
  · obtain ⟨hesc, hsz⟩ := Shapes.clearHome_keeps hcl
    have hbs : BytesRel (List.replicate (R.handlerHome S.c.mode.pe n) .uninit)
        (bytesAt x.mem (fpAddr x (-(S.F : Int)))
          (List.replicate (R.handlerHome S.c.mode.pe n) AbstractByte.uninit).length) := by
      rw [List.length_replicate]
      have := Ryo.Proofs.ArgRet.BytesRel.uninit
        (bytesAt x.mem (fpAddr x (-(S.F : Int))) (R.handlerHome S.c.mode.pe n))
      rwa [bytesAt_length] at this
    have hr' := (CallLemmas.rel_writeFrame_in
      (fun o h1 h2 _ b hb => hf.rrel.rel.frame o h1 h2 b hb) hf.rrel.rel.layout
      hf.rrel.rel.zeroSized hw (by omega) (by rw [List.length_replicate]; omega) hbs).1
    exact { hf with
      rrel := ⟨hr', hf.rrel.rbp, hf.rrel.wf.of_sizes hesc hsz⟩
      mem := ScopeMem.memRel_writeUninit hf.mem hw
      sep := island_sep_writeFrame hf.sep hw (Int.le_refl _) (by rw [List.length_replicate]; omega)
      slots := hf.slots.clearHome hcl
      esc := hf.esc.congr hesc }
  · exact hf

/-- `hdl_frameCore_clear` for `FrameInv`. -/
theorem hdl_frameInv_clear (H : Hyps S) {s : R.RState} {x : X86.State} {st'' : OpSem.State}
    {n : Nat} (hf : FrameInv S s x) (hn : R.handlerHome S.c.mode.pe n ≤ S.F)
    (hcl : R.clearHome S.c.mode.pe n (-(S.F : Int)) s.st = .ok st'') :
    FrameInv S { s with st := st'' } x :=
  FrameInv.ofCore (hdl_frameCore_clear H hf.toCore hn hcl) hf.rsp hf.room hf.args

set_option maxRecDepth 100000 in
/-- A handler leaves the code, the rodata and the frame's link slots alone, and none is on the
stack below `rsp` (as `island_kept'`: the frame writes lie in the window, `FrameBounds.handler`,
and off the link slots, `FrameBounds.handlerOff`). -/
theorem hdl_kept (H : Hyps S) {s s1 : R.RState} {x x2 xb : X86.State} (hf : FrameInv S s x)
    (hbi : BInv S s xb)
    (hsc : (S.c.scopesAt s.pc).foldlM R.applyScope s = .ok s1)
    {h : Full.Opcode} {args : List R.Arg} {t : R.Then Nat} {vals : Operands}
    (hi : S.c.d.insns[s.pc]? = some (.handler h args t))
    (hu : R.unpack S.c.ρ h S.c.mode args = some vals)
    (hrbp2 : x2.reg .rbp = x.reg .rbp) (hrsp2 : x2.rsp.toNat ≤ x.rsp.toNat)
    (hrsp2e : x2.rsp = x.rsp - 8) (hhome : R.handlerHome S.c.mode.pe args.length ≤ S.F)
    (b : BitVec 64) (hb : IslandKept S x b) :
    ¬ Handler.MayWrite S.Owned S.lo (R.handlerHome S.c.mode.pe args.length) h vals s1.st x2 b ∧
      ¬ InStack S.lo x.rsp b := by
  have hK : (16 : Int) ≤ S.K := by have := H.argSizeK; omega
  have hwin : (s.fp : Int) + S.K ≤ 2 ^ 64 := hf.win
  have hfpF : S.F ≤ s.fp := hf.fpF
  have hfb := H.frameBounds
  have hFle : (S.F : Int) ≤ 2 ^ 31 := hfb.F_le
  have hKle : S.K ≤ 2 ^ 31 := hfb.K_le
  have hrsp0 : x.rsp.toNat = s.fp - S.F := island_rsp_toNat hf.rrel.rbp (by omega) hfpF hf.rsp
  have hrbp : x.reg .rbp = BitVec.ofNat 64 s.fp := hf.rrel.rbp
  have hrbpX2 : x2.reg .rbp = BitVec.ofNat 64 s.fp := hrbp2.trans hrbp
  have hW : ∀ o, S.winAddr o = BitVec.ofNat 64 s.fp + BitVec.ofInt 64 o := fun o => by
    rw [← hf.fpAddr_eq]; simp [fpAddr, hrbp]
  have hwr : WrIn (-(S.F : Int)) S.K h vals := hfb.handler s.pc h args t vals hi hu
  -- A home byte (PE's home space and stack argument, `[x2.rsp + 8, + home)`): the frame offsets
  -- `[-F, -F + home)`, below the link slots.
  have hhomeW : ∀ b, (b - (x2.rsp + 8)).toNat < R.handlerHome S.c.mode.pe args.length →
      ∃ o : Int, -(S.F : Int) ≤ o ∧ o < 0 ∧ b = fpAddr x o := by
    intro b hb
    have e8 : x2.rsp + 8 = x.rsp := by rw [hrsp2e]; exact BitVec.sub_add_cancel _ _
    rw [e8] at hb
    have hx : x.rsp = fpAddr x (-(S.F : Int)) := by
      apply BitVec.eq_of_toNat_eq
      rw [HandlerStackArg.fpAddr_toNat hrbp (o := -(S.F : Int)) (by omega) (by omega), hrsp0]
      omega
    refine ⟨-(S.F : Int) + ((b - x.rsp).toNat : Nat), by omega, by omega, ?_⟩
    calc b = x.rsp + BitVec.ofNat 64 (b - x.rsp).toNat := island_sub_toNat rfl
      _ = fpAddr x (-(S.F : Int)) + BitVec.ofNat 64 (b - x.rsp).toNat := by rw [← hx]
      _ = _ := by simp only [fpAddr, island_ofInt_add, BitVec.add_assoc]
  -- A byte off the window: in no frame write range.
  have hwr_win : ∀ b, (∀ o : Int, -(S.F : Int) ≤ o → o < S.K → b ≠ S.winAddr o) →
      ¬ ∃ r ∈ wranges h vals, (b - fpAddr x2 r.1).toNat < r.2 := by
    rintro b hnw ⟨r, hr, hlt⟩
    have hr' := hwr r hr
    rw [Island.fpAddr_eq_lendAddr hrbpX2] at hlt
    refine hnw (r.1 + (b - Island.lendAddr s.fp r.1).toNat) (by omega) (by omega) ?_
    rw [hW, island_ofInt_add, ← BitVec.add_assoc]
    exact island_sub_toNat rfl
  -- A code or rodata byte.
  have hcode : ∀ b, ((∃ p, p < S.body.code.size ∧ b = addrAt S.ctx p) ∨
      (∃ j, j < S.ro.size ∧ b = S.ctx.addrOf (.ro j))) →
      ¬ Handler.MayWrite S.Owned S.lo (R.handlerHome S.c.mode.pe args.length) h vals s1.st x2 b ∧
        ¬ InStack S.lo x.rsp b := by
    intro b hb'
    obtain ⟨hown, hstk, hnw, hal⟩ := H.codeApart b hb'
    have hst : ¬ InStack S.lo x.rsp b := hdl_inStack_lift H hf hstk
    refine ⟨?_, hst⟩
    rintro (hwb | hal1 | ho | hst2 | hh)
    · exact hwr_win b hnw hwb
    · have hold : island_AllOk (fun addr sz => ¬ (b - BitVec.ofNat 64 addr).toNat < sz) s.st :=
        fun id al hg hl hlt => hal s _ hbi ⟨id, al, hg, hl, hlt⟩
      have hnew := island_allOk_foldlM (P := fun addr sz => ¬ (b - BitVec.ofNat 64 addr).toNat < sz)
        (F := S.F) (K := S.K) _ (fun off sz h1 h2 h3 hlt => by
          refine hnw (off + (b - BitVec.ofNat 64 ((s.fp : Int) + off).toNat).toNat)
            (by omega) (by omega) ?_
          rw [hW, island_ofInt_add, ← BitVec.add_assoc, ← ofNat_frameAddr _ _ h3]
          exact island_sub_toNat rfl) (hfb.scopesIn s.pc) hold hsc
      obtain ⟨id, al, hg, hl, hlt⟩ := hal1
      exact hnew id al hg hl hlt
    · exact hown ho
    · exact hst ⟨hst2.1, Nat.lt_of_lt_of_le hst2.2 hrsp2⟩
    · obtain ⟨o, h1, h2, he⟩ := hhomeW b hh
      exact hnw o h1 (by omega) (he.trans (hf.fpAddr_eq o))
  rcases hb with hb | ⟨r, hr, k, hk, rfl⟩ | hb | ⟨i, hi', hb⟩
  · exact hcode b (.inl hb)
  · exact hcode _ (.inl ⟨r.pos + k, by have := H.relocsIn r hr; omega, rfl⟩)
  · exact hcode b (.inr hb)
  · -- A link slot: `fp + o` with `o ∈ [0, 16)`.
    obtain ⟨o, ho1, ho2, rfl⟩ : ∃ o : Int, 0 ≤ o ∧ o < 16 ∧ b = fpAddr x o := by
      have e : ∀ c : Int, x.reg .rbp + BitVec.ofInt 64 c + BitVec.ofNat 64 i =
          fpAddr x (c + i) := fun c => by
        simp only [fpAddr, island_ofInt_add, BitVec.add_assoc]
      rcases hb with rfl | rfl
      · refine ⟨8 + i, by omega, by omega, ?_⟩
        rw [← e]; rfl
      · refine ⟨0 + i, by omega, by omega, ?_⟩
        rw [← e]; simp
    have hoF : -(S.F : Int) ≤ o := by omega
    obtain ⟨hesc, -⟩ := H.linkPrivate s x s1 hf hsc o ho1 ho2
    have hxo : (fpAddr x o).toNat = ((s.fp : Int) + o).toNat := by
      rw [Island.fpAddr_eq_lendAddr hrbp, Island.lendAddr, ← ofNat_frameAddr _ _ (by omega),
        BitVec.toNat_ofNat, Nat.mod_eq_of_lt (by omega)]
    have hst : ¬ InStack S.lo x.rsp (fpAddr x o) := by
      rintro ⟨-, h2⟩
      rw [hrsp0, hxo] at h2
      omega
    refine ⟨?_, hst⟩
    rintro (⟨r, hr, hlt⟩ | ⟨id, al, hg, hlv, hlt⟩ | ho | hst2 | hh)
    · have hli := hwr r hr
      have hoff := hfb.handlerOff s.pc h args t vals hi hu r hr
      have e2 : fpAddr x2 r.1 = fpAddr x r.1 := by simp [fpAddr, hrbp2]
      rw [e2, fpAddr_sub, BitVec.toNat_ofInt] at hlt
      have hsz : r.2 < 2 ^ 62 := by omega
      simp only [OffLink] at hoff
      omega
    · have hsep1 := (sep_foldlM _ (hfb.scopesIn _) (hfb.window hwin) hf.rrel hf.sep hsc).2
      obtain ⟨e, hem, he1, he2, -⟩ := hsep1.own id al o hg hlv hoF (by omega) hlt
      exact escapedAt_none hesc e hem ⟨he1, he2⟩
    · rw [hf.fpAddr_eq] at ho
      exact H.envApart.window o hoF (by omega) ho
    · exact hst ⟨hst2.1, Nat.lt_of_lt_of_le hst2.2 hrsp2⟩
    · obtain ⟨o', h1, h2, he⟩ := hhomeW _ hh
      have := congrArg BitVec.toNat he
      rw [HandlerStackArg.fpAddr_toNat hrbp (o := o) (by omega) (by omega),
        HandlerStackArg.fpAddr_toNat hrbp (o := o') (by omega) (by omega)] at this
      omega

set_option maxHeartbeats 1000000 in
/-- The setup, `call h` and the handler's return (`H.handler`, `SepAcross.handler`): each return
continues at the item after the call with `opSem`'s result for a choice, its control in the
return registers, and `FrameInv` of R's state after (with PE's home space cleared,
`R.clearHome`) for any successor past the leading `arg`s (the frame writes in the window,
`FrameBounds.handler`; the code, rodata and link slots kept, `hdl_kept`; the home bytes the
handler may write, `[-F, -F + handlerHome)`, below the link slots, `hdl_home_le`).

In either frame form: `x` is the virtual state the setup runs from (`FrameInv`), `xr` the real
one the machine is in; `hsteps4`/`hsteps5` fetch the setup and the call from `xr` to the real
state after (`rbp = r`), the handler runs from it under `HandlerContractB` with the frame pointer
`x.reg .rbp` (`hfpIn`: a handler reading `fp` from `rbp` finds it there) and `hsepB`; each
return continues with the real state and the relation of its virtual one (`rbp := x.reg .rbp`). -/
theorem hdl_call_reach (_hD : Decodes S code relocs rodata callSites dropped scopes mode)
    (H : Hyps S)
    {Q : X86.State → Prop} {s s1 : R.RState} {xr x xb : X86.State} {n pEnd : Nat}
    {r : BitVec 64}
    {h : Full.Opcode} {args : List R.Arg} {t : R.Then Nat} {vals : Operands} {items : List Item}
    (hf : FrameInv S s x) (hbi : BInv S s xb)
    (hn : Full.Opcode.ofNat? n = some h) (hhh : h.hasHandler = true)
    (hsetup : Handler.setupItems S.c.mode args = some items)
    (hi : S.c.d.insns[s.pc]? = some (.handler h args t))
    (hsc : (S.c.scopesAt s.pc).foldlM R.applyScope s = .ok s1)
    (hu : R.unpack S.c.ρ h S.c.mode args = some vals) (hno : Handler.NoUB h vals s1.st)
    (hripE : x.rip + BitVec.ofNat 64 (codeSize (items ++ [Item.call (.handler n)])) =
      addrAt S.ctx pEnd)
    (hfpIn : S.c.mode.fpArg = false → r = x.reg .rbp)
    (hsepB : SepAcrossHB S r (x.reg .rbp))
    (hsteps4 : args.length ≤ (handlerRegs S.c.mode.pe).length → ∀ x2,
      execItems S.ctx (items ++ [Item.call (.handler n)]) x = .ok x2 →
      x2.reg .rbp = x.reg .rbp → Steps S.ctx xr (x2.setReg .rbp r))
    (hsteps5 : S.c.mode.pe = true → ∀ x2,
      (∀ a, (∃ j, j < S.body.code.size ∧ a = addrAt S.ctx j) →
        ¬ HandlerStackArg.InStackArg x.rsp a) →
      execItems S.ctx (items ++ [Item.call (.handler n)]) x = .ok x2 →
      x2.reg .rbp = x.reg .rbp → Steps S.ctx xr (x2.setReg .rbp r))
    (kont : ∀ x' ch ctl st', opSem h vals s1.st ch = .ok (ctl, st') → Handler.CtlIn ctl x' →
      x'.rip = addrAt S.ctx pEnd → x'.rsp = x.rsp → x'.reg .rbp = r →
      (∀ st'', R.clearHome S.c.mode.pe args.length (-(S.F : Int)) st' = .ok st'' →
        ∀ pc, ¬ LeadArg S pc →
          FrameInv S { s1 with pc, st := st'' } (x'.setReg .rbp (x.reg .rbp))) →
      Reach S.ctx S.E Q x') :
    Reach S.ctx S.E Q xr := by
  have hk := scopes_keeps _ hsc
  have hfb := H.frameBounds
  have hwinT : (s.fp : Int) + S.K ≤ 2 ^ 64 := hf.win
  have hfpF : S.F ≤ s.fp := hf.fpF
  obtain ⟨hrbN, hrspN, -, hfp16, -, -, hK16⟩ := hdl_nums H hf
  have hsep1 : FrameSep (-(S.F : Int)) S.K s1.st x :=
    (sep_foldlM _ (hfb.scopesIn s.pc) (hfb.window hwinT) hf.rrel hf.sep hsc).2
  obtain ⟨hr1, hm1⟩ := memRel_foldlM _ (hfb.scope_size _) hf.rrel hf.mem hsc
  have hap : Handler.StackApart S.lo s1.st x :=
    Handler.FrameSep.stackApart hsep1
      (Handler.stack_off_window (by rw [hrbN, hrspN]; omega) (by rw [hrbN]; omega))
      (island_allocs' H hf hsc)
  have hlo : S.lo.toNat + 8 ≤ x.rsp.toNat := by have := hf.room; omega
  -- The setup and `call h`: arguments in registers (`handler_call_ret`), or PE's five with the
  -- stack argument (`HandlerStackArg.handler_call5`, the store's bytes off the relations by
  -- `H.peStackArg`).
  obtain ⟨x2, hsteps, hat2, hargs2, hrsp2, hsv2, hmem2, hra, hH2, hrbp2⟩ :
      ∃ x2, Steps S.ctx xr (x2.setReg .rbp r) ∧ Handler.AtHandler S.ctx h x2 ∧
        Handler.ArgsIn S.c.ρ S.c.mode.pe x2 x2 args ∧ x2.rsp = x.rsp - 8 ∧
        (∀ i, Saved S.c.mode.pe i → x2.regs i = x.regs i) ∧
        (∀ a, ¬ InStack S.lo x.rsp a → IslandKept S x a → x2.mem a = x.mem a) ∧
        x2.mem.read64 x2.rsp = addrAt S.ctx pEnd ∧
        Handler.HRel s1.st x2 ∧ x2.reg .rbp = x.reg .rbp := by
    rcases HandlerStackArg.setupItems_length hsetup with hreg | ⟨hpe, h5⟩
    · obtain ⟨x2, hx2, hat2, hargs2, hrsp2, hsv2, hmem2, hret2⟩ :=
        handler_call_ret (lo := S.lo) S.ctx H.linked hn hsetup hreg hlo
      obtain ⟨x2', hx2', -, -, hH2, hrbp2, -, -⟩ :=
        handler_call (lo := S.lo) S.ctx H.linked hn hsetup hreg ⟨hr1.rel, hm1⟩ hap hlo
      have e2 : x2' = x2 := by
        rw [hx2] at hx2'
        exact (Switch.except_ok_inj hx2').symm
      rw [e2] at hH2 hrbp2
      refine ⟨x2, hsteps4 hreg x2 hx2 hrbp2, hat2, hargs2, hrsp2, hsv2,
        fun a ha _ => hmem2 a ha, ?_, hH2, hrbp2⟩
      rw [hret2]; exact hripE
    · obtain ⟨a0, a1, a2, a3, a4, rfl⟩ := HandlerStackArg.eq_five h5
      obtain ⟨hF36, hpriv⟩ := H.peStackArg hpe s.pc h _ t hi h5
      have hfp64 : s.fp < 2 ^ 64 := by omega
      have hb : x.reg .rbp = BitVec.ofNat 64 s.fp := hf.rrel.rbp
      obtain ⟨x2, hx2, hat2, hargs2, hrsp2, hrbp2, hpk, hmem2, hret2⟩ :=
        HandlerStackArg.handler_call5 (lo := S.lo) S.ctx H.linked hpe hn hsetup hlo
      have harg : HandlerStackArg.ArgApart (HandlerStackArg.InStackArg x.rsp) s1.st x :=
        HandlerStackArg.stackArg_apart hb hrspN hF36 hfpF hfp64 hwinT (by omega) hsep1
          (hpriv s x s1 hf rfl hsc)
      have hH2 := HandlerStackArg.hrel_after ⟨hr1.rel, hm1⟩ hap harg hrbp2 hmem2
      -- Code and rodata bytes are off the window, so off the stack argument.
      have hcodeOff : ∀ a, ((∃ j, j < S.body.code.size ∧ a = addrAt S.ctx j) ∨
          (∃ j, j < S.ro.size ∧ a = S.ctx.addrOf (.ro j))) →
          ¬ HandlerStackArg.InStackArg x.rsp a := by
        intro a ha hin
        obtain ⟨j', hj', he⟩ :=
          HandlerStackArg.inStackArg_eq_fpAddr hb hrspN hF36 hfpF hfp64 hin
        exact (H.codeApart a ha).2.2.1 (-(S.F : Int) + 32 + j') (by omega) (by omega)
          (he.trans (hf.fpAddr_eq _))
      refine ⟨x2, hsteps5 hpe x2 (fun a ha => hcodeOff a (.inl ha)) hx2 hrbp2, hat2, hargs2,
        hrsp2, ?_, ?_, ?_, hH2, hrbp2⟩
      · intro i hi
        rcases hi with (rfl | rfl | rfl | rfl | rfl | rfl) | ⟨-, rfl | rfl⟩ <;>
          refine hpk _ (fun r hr => ?_) (by decide) <;>
          (rw [hpe] at hr
           simp [handlerRegs] at hr
           rcases hr with rfl | rfl | rfl | rfl <;> decide)
      · intro a ha hk
        refine hmem2 a ha ?_
        rcases hk with hk | ⟨r, hr, kk, hkk, rfl⟩ | hk | ⟨i, hi', hk⟩
        · exact hcodeOff a (.inl hk)
        · exact hcodeOff _ (.inl ⟨r.pos + kk, by have := H.relocsIn r hr; omega, rfl⟩)
        · exact hcodeOff a (.inr hk)
        · -- A link slot: `fp + o` with `o ∈ [0, 16)`.
          obtain ⟨o, ho1, ho2, rfl⟩ : ∃ o : Int, 0 ≤ o ∧ o < 16 ∧ a = fpAddr x o := by
            have e : ∀ c : Int, x.reg .rbp + BitVec.ofInt 64 c + BitVec.ofNat 64 i =
                fpAddr x (c + i) := fun c => by
              simp only [fpAddr, island_ofInt_add, BitVec.add_assoc]
            rcases hk with rfl | rfl
            · refine ⟨8 + i, by omega, by omega, ?_⟩
              rw [← e]; rfl
            · refine ⟨0 + i, by omega, by omega, ?_⟩
              rw [← e]; simp
          exact HandlerStackArg.not_inStackArg_fpAddr hb hrspN hF36 hfpF hfp64 (by omega)
            (by omega)
      · rw [hret2]; exact hripE
  have hrsp2le : x2.rsp.toNat ≤ x.rsp.toNat := by
    have h8 : (x.rsp - 8).toNat = x.rsp.toNat - 8 := by
      rw [BitVec.toNat_sub]; have := x.rsp.isLt; simp; omega
    rw [hrsp2, h8]; omega
  -- The home bytes (PE's home space and stack argument) at `x2.rsp + 8 = fp - F`.
  have hHome := hdl_home_le H hi
  have hxF : x.rsp = fpAddr x (-(S.F : Int)) := by
    apply BitVec.eq_of_toNat_eq
    rw [HandlerStackArg.fpAddr_toNat hf.rrel.rbp (o := -(S.F : Int)) (by omega) (by omega),
      hrspN]
    omega
  have hho : fpAddr x2 (-(S.F : Int)) = x2.rsp + 8 := by
    rw [hrsp2, BitVec.sub_add_cancel, hxF]; simp [fpAddr, hrbp2]
  have hown : FrameOwn (-(S.F : Int)) (-(S.F : Int) + R.handlerHome S.c.mode.pe args.length)
      s1.st x2 := by
    intro id a o hg hl h1 h2 hin
    have e : fpAddr x2 o = fpAddr x o := by simp [fpAddr, hrbp2]
    rw [e] at hin
    exact hsep1.own id a o hg hl h1 (by omega) hin
  -- The handler runs from the real state; its relations read with `rbp := x.reg .rbp`.
  have hx2b : (x2.setReg .rbp r).setReg .rbp (x.reg .rbp) = x2 := by
    rw [vt_setReg_setReg, ← hrbp2, X86.State.setReg_reg_self]
  have hx2rsp : (x2.setReg .rbp r).rsp = x2.rsp := Handler.setRbp_rsp x2 r
  have hx2rbp : (x2.setReg .rbp r).reg .rbp = r := X86.State.reg_setReg x2 .rbp r
  have hat2r : Handler.AtHandler S.ctx h (x2.setReg .rbp r) := hat2
  have hargs2r : Handler.ArgsIn S.c.ρ S.c.mode.pe ((x2.setReg .rbp r).setReg .rbp (x.reg .rbp))
      (x2.setReg .rbp r) args := by
    rw [hx2b]
    refine ⟨fun i h1 h2 => ?_, fun h1 hpe => ?_⟩
    · rw [hargs2.1 i h1 h2, Handler.setRbp_reg x2 r _
        (Handler.handlerRegs_ne_rbp _ _ (List.getElem_mem h2))]
    · obtain ⟨w, hw1, hw2, hw3⟩ := hargs2.2 h1 hpe
      exact ⟨w, hw1, hw2, by rw [Handler.setRbp_rsp]; exact hw3⟩
  have hH2r : Handler.HRel s1.st ((x2.setReg .rbp r).setReg .rbp (x.reg .rbp)) := by
    rw [hx2b]; exact hH2
  have hhor : fpAddr ((x2.setReg .rbp r).setReg .rbp (x.reg .rbp)) (-(S.F : Int)) =
      (x2.setReg .rbp r).rsp + 8 := by
    rw [hx2b, hx2rsp]; exact hho
  have hownr : FrameOwn (-(S.F : Int)) (-(S.F : Int) + R.handlerHome S.c.mode.pe args.length)
      s1.st ((x2.setReg .rbp r).setReg .rbp (x.reg .rbp)) := by
    rw [hx2b]; exact hown
  refine Reach.steps hsteps (.env (H.envOutside.handler h _ hat2r) fun x' hret => ?_)
  -- The return.
  obtain ⟨ch, ctl, st', hop, hH', hctl, hal⟩ :=
    hsepB h args vals s1.st (x2.setReg .rbp r) x' x hx2rbp hhh hu hat2r hargs2r hH2r hno hret
      hsep1 hhor
  obtain ⟨-, -, -, -, -, -, hrsp', hrip', hsv', hmw⟩ :=
    H.handler.sound h args vals s1.st (x2.setReg .rbp r) x' (x.reg .rbp) hhh hu hat2r
      (fun hfa => hx2rbp.trans (hfpIn hfa)) hargs2r hH2r hno _ hhor hownr hret
  have hx'rbp : x'.reg .rbp = r := by
    show x'.regs 5 = r
    rw [hsv' 5 (by simp [CalleeSaved])]
    exact hx2rbp
  have hx'rsp : x'.rsp = x.rsp := by
    rw [hrsp', hx2rsp, hrsp2]; exact BitVec.sub_add_cancel _ _
  refine kont x' ch ctl st' hop hctl (by rw [hrip', hx2rsp]; exact hra) hx'rsp hx'rbp
    fun st'' hcl pc hnl => ?_
  have hrbp' : (x'.setReg .rbp (x.reg .rbp)).reg .rbp = x.reg .rbp :=
    X86.State.reg_setReg x' .rbp _
  have hrspX : (x'.setReg .rbp (x.reg .rbp)).rsp = x.rsp := by
    rw [Handler.setRbp_rsp]; exact hx'rsp
  have hsvX : ∀ i, Saved S.c.mode.pe i → (x'.setReg .rbp (x.reg .rbp)).regs i = x.regs i := by
    intro i hi
    by_cases h5 : i = 5
    · subst h5; exact X86.State.reg_setReg x' .rbp _
    · have e1 : (x'.setReg .rbp (x.reg .rbp)).regs i = x'.regs i := by
        show (if i = Reg.rbp.idx then _ else x'.regs i) = x'.regs i
        rw [if_neg (fun h => h5 (h.trans (by decide)))]
      have e2 : (x2.setReg .rbp r).regs i = x2.regs i := by
        show (if i = Reg.rbp.idx then _ else x2.regs i) = x2.regs i
        rw [if_neg (fun h => h5 (h.trans (by decide)))]
      rw [e1]
      rcases hi with hc | ⟨hpe, h67⟩
      · rw [hsv' i hc, e2]; exact hsv2 i (Or.inl hc)
      · obtain ⟨h6, h7⟩ := H.peSaved hpe _ x' hret
        rcases h67 with rfl | rfl
        · rw [h6, e2]; exact hsv2 6 (Or.inr ⟨hpe, Or.inl rfl⟩)
        · rw [h7, e2]; exact hsv2 7 (Or.inr ⟨hpe, Or.inr rfl⟩)
  have hkeep : ∀ b, IslandKept S x b → (x'.setReg .rbp (x.reg .rbp)).mem b = x.mem b := by
    intro b hb
    obtain ⟨h1, h2⟩ := hdl_kept H hf hbi hsc hi hu hrbp2 hrsp2le hrsp2 hHome b hb
    show x'.mem b = x.mem b
    rw [hmw b (by rw [hx2b]; exact h1)]
    exact hmem2 b h2 hb
  -- The frame separation after the handler.
  have hesc : st'.escaped = s1.st.escaped := (Ryo.Proofs.OpFacts.opSem_out hop).2.1
  have hwr : WrIn (-(S.F : Int)) S.K h vals := hfb.handler s.pc h args t vals hi hu
  have hinit : FrameInit (-(S.F : Int)) S.K st' := by
    intro o he hu'
    have he1 : s1.st.escapedAt o = none := by
      rw [← IslandLemmas.escapedAt_congr hesc o]; exact he
    by_cases hin : ∃ r ∈ wranges h vals, inRange o r = true
    · obtain ⟨r, hr, ho⟩ := hin
      have := hwr r hr
      simp only [inRange, decide_eq_true_eq] at ho
      omega
    · obtain ⟨fp, hfp⟩ := hdl_footprint hop
      have hw : wranges h vals = fp.writeRanges (opndVal h.info vals) := by
        unfold wranges; rw [hfp]
      have hfr : st'.frame o = s1.st.frame o := opSem_frame_writes hfp hop o fun r hr => by
        cases hc : inRange o r
        · rfl
        · exact absurd ⟨r, hw ▸ hr, hc⟩ hin
      exact hsep1.init o he1 (by rw [← hfr]; exact hu')
  have hsep' : FrameSep (-(S.F : Int)) S.K st' (x'.setReg .rbp (x.reg .rbp)) :=
    FrameSep.extend hsep1 hrbp' hesc hal.1 hinit hal.2.1 hal.2.2
  have hwf' : EscWF st' := (H.opFacts h).escWF vals s1.st ch ctl st' hop hr1.wf
  have hslots' := (H.slots_scopes hf hsc).opSem hop (Discharge.PeStackArg.handler_lo H.boundsOk hi hu)
  -- PE's home space cleared (`R.clearHome`): `Uninit`, inside the window.
  have hH'' := hH' st'' hcl hx'rbp
  obtain ⟨hesc'', hsz''⟩ := Shapes.clearHome_keeps hcl
  have hwf'' : EscWF st'' := hwf'.of_sizes hesc'' hsz''
  obtain ⟨hsep'', hslots''⟩ :
      FrameSep (-(S.F : Int)) S.K st'' (x'.setReg .rbp (x.reg .rbp)) ∧
        Discharge.PeStackArg.ArgSlots S.c st'' := by
    rcases Shapes.clearHome_cases hcl with ⟨-, hw⟩ | ⟨-, rfl⟩
    · exact ⟨island_sep_writeFrame hsep' hw (Int.le_refl _) (by rw [List.length_replicate]; omega),
        hslots'.clearHome hcl⟩
    · exact ⟨hsep', hslots'.clearHome hcl⟩
  refine ⟨⟨hH''.rel, ?_, hwf''⟩, hH''.mem, hsep'', ?_, ?_, ?_, ?_, island_link_keptF hf.code hkeep,
    island_ro_kept hf.ro hkeep, fun ha => absurd ha hnl,
    island_frame_kept hf.frame hkeep hrbp' (fun i hi _ => hsvX i hi), hslots'',
    ((hf.esc.scopes hsc).of_not hnl).congr (hesc''.trans hesc)⟩
  · show (x'.setReg .rbp (x.reg .rbp)).reg .rbp = BitVec.ofNat 64 s1.fp
    rw [hrbp', hf.rrel.rbp, hk.fp]
  · show (s1.fp : Int) + S.K ≤ 2 ^ 64
    rw [hk.fp]; exact hwinT
  · show S.F ≤ s1.fp
    rw [hk.fp]; exact hfpF
  · rw [hrspX, hrbp']; exact hf.rsp
  · rw [hrspX]; exact hf.room

@[simp] theorem hdl_fform_testAl (fb : FForm) : FForm.item fb Item.testAl = .testAl := by
  cases fb <;> rfl

theorem hdl_fform_switch (fb : FForm) (tb : BitVec 32) :
    (Switch.switchItems tb).map (FForm.item fb) = Switch.switchItems tb := by
  cases fb <;> rfl

/-- Falling through to instruction `k + 1` at `pC` (after PE's `nop`, as in `bodySim_island`), in
either frame form (`y` real; PE's `nop` only with a frame pointer, `Mode.valid`). -/
theorem hdl_fallthrough (hD : Decodes S code relocs rodata callSites dropped scopes mode)
    {k pC : Nat} {q : Proto} {s s' : R.RState} {y : X86.State}
    (hnop : NopRead S.fr S.callSites S.body q pC (S.start (k + 1)))
    (hlk : LinkOkF S.ctx y.mem S.body S.rs S.c.mode) (hb : Boundary S.rs pC)
    (hyrip : y.rip = addrAt S.ctx pC) (hnext : RNext S.c s s') (hpc : s'.pc = k + 1)
    (hfi : FrameInvR S s' y) (hcache : S.cache (k + 1) = { pe := S.fr.mode.pe }) :
    Reach S.ctx S.E (SNextE S s) y := by
  have fin : ∀ z : X86.State, z.regs = y.regs → z.xmm = y.xmm → z.mem = y.mem →
      z.rip = addrAt S.ctx (S.start (k + 1)) → Reach S.ctx S.E (SNextE S s) z := by
    intro z hzr hzx hzm hzrip
    refine .done (.inl ⟨s', hnext, ⟨hfi.congr' hzr hzx hzm, .inl ⟨?_, ?_⟩⟩, .inl ⟨?_, ?_⟩⟩)
    · rw [hpc]; exact hzrip
    · rw [hpc, hcache]; exact CacheInv.emptyPe _ _
    · rw [hpc]; exact hzrip
    · rw [hpc]; exact hcache
  generalize hE : S.start (k + 1) = pE at hnop fin
  cases hnop with
  | none _ => exact fin y rfl rfl rfl hyrip
  | nop hna hby hrl =>
    have hpe : S.c.mode.pe = true := by
      unfold nopAfter at hna
      simp only [Bool.and_eq_true] at hna
      exact hna.1.1
    obtain ⟨hit, -, -⟩ := nop_itemAt (hlk.toLinkOk (vt_fp_of_pe hD.modeValid hpe)) (p := pC)
      (n := 1) (by omega) (by omega) (island_nop_bytes hby) hrl hb
    refine reach_padding (ns := [1]) (by simp) ⟨hit, trivial⟩ hyrip fun z h1 h2 h3 h4 => ?_
    refine fin z h1 h2 h3 ?_
    rw [h4]; rfl

set_option maxHeartbeats 1000000 in
/-- The `br` shape's tail after the return: `test al, al; jz/jnz tgt` (`Handler.br_tail`), to the
target (not a leading `arg`, `ArgsOk.untargeted`; the cache cleared there,
`CacheCleared.targets`) or falling through. -/
theorem hdl_br (hD : Decodes S code relocs rodata callSites dropped scopes mode) (H : Hyps S)
    {k pT j pc : Nat} {q : Proto} {c3 : Cursor} {s s1 : R.RState}
    {x' : X86.State} {st' : OpSem.State} {ch : OpSem.Choice} {b : Bool} {cond : Cond}
    {tgt : BitVec 32} {long : Bool}
    (hs : s.pc = k) (hlt : k < S.r.protos.size)
    (htg : tgt.toNat ∈ S.r.protos[k].targets) (hj : posOf S.r j = tgt.toNat)
    (hcond : cond = .z ∨ cond = .nz)
    (hdec : Dec (atPos S.body pT) pT [.testAl, .branch cond tgt long] c3.pos)
    (hbT0 : Boundary S.rs pT) (hrip : x'.rip = addrAt S.ctx pT)
    (hal : Handler.CtlIn (.branch b) x')
    (hFI : ∀ pc, ¬ LeadArg S pc → FrameInvR S { s1 with pc, st := st' } x')
    (hpc : (if (b != (cond == Cond.z)) = true then j else s.pc + 1) = pc)
    (hstep : R.step S.c s ch = .ok (.step { s1 with pc, st := st' }))
    (hnl : ¬ LeadArg S (k + 1))
    (hnop : NopRead S.fr S.callSites S.body q c3.pos (S.start (k + 1)))
    (hcache : S.cache (k + 1) = { pe := S.fr.mode.pe }) :
    Reach S.ctx S.E (SNextE S s) x' := by
  have hce : cond = (if (cond == Cond.z) = true then Cond.z else Cond.nz) := by
    rcases hcond with rfl | rfl <;> rfl
  have hnl' : ¬ LeadArg S (s.pc + 1) := by rw [hs]; exact hnl
  have hfk := hFI (s.pc + 1) hnl'
  have hlkT : LinkOkF S.ctx x'.mem (atPos S.body pT) S.rs S.c.mode := hfk.code'.atPos pT
  obtain ⟨hcaT, hqT, hbT⟩ := hlkT.dec hdec hbT0
  simp only [List.map_cons, List.map_nil, hdl_fform_testAl, fform_item_branch] at hcaT hqT
  obtain ⟨n1, n2, h1, h2, -⟩ := hdl_dec2 hdec
  obtain ⟨-, hq1, -⟩ := hlkT.dec (Dec.single h1) hbT0
  simp only [List.map_cons, List.map_nil, hdl_fform_testAl] at hq1
  have hn1 : n1 = Item.testAl.size := by
    simp only [codeSize, List.map_cons, List.map_nil, List.sum_cons, List.sum_nil] at hq1
    omega
  have hcanB : (Item.branch cond tgt long).Canonical (pT + Item.testAl.size) := by
    rw [← hn1]; exact branch_canonical_any (c := S.body) h2
  have hcanA : Item.testAl.Canonical pT := by
    unfold Item.Canonical
    exact ⟨fun _ _ h => (nomatch h), Or.inl rfl⟩
  have hcan : Canon [Item.testAl, Item.branch cond tgt long] pT := ⟨hcanA, hcanB, trivial⟩
  obtain ⟨x'', hex, hregs, hmem, hxmm, hrip2⟩ :=
    Handler.br_tail S.ctx b (cond == Cond.z) tgt long x' hal
  rw [← hce] at hex hrip2
  have hst : Steps S.ctx x' x'' :=
    steps_of_run_last (S := InCode S.ctx [Item.testAl, Item.branch cond tgt long] pT)
      (items := [Item.testAl]) (j := Item.branch cond tgt long) hcan hcaT hrip (fun _ h => h)
      (fetchRun_of_forall (fun i hi => by
        simp only [List.mem_singleton] at hi
        subst hi
        exact hdl_testAl_straight S.ctx) x') hex
  rcases Bool.eq_false_or_eq_true (b != (cond == Cond.z)) with hbn | hbn
  · -- Taken: to the target.
    rw [ite_eq_left hbn] at hpc
    rw [ite_eq_left hbn] at hrip2
    rw [← hpc] at hstep
    have hnlj : ¬ LeadArg S j := H.argsUntargeted hD k hlt _ htg j hj
    have hfj := (hFI j hnlj).congr' hregs hxmm hmem
    have hc := H.cacheTargets k hlt _ htg
    have hripj : x''.rip = addrAt S.ctx (posOf S.r j) := by
      rw [hrip2, hdl_base_setWidth, hj]
    have hused : S.used j = { pe := S.c.mode.pe } := by
      simp only [Setup.used, hj, hc, ↓reduceIte]
    refine Reach.steps hst (.done (.inl ⟨_, .step hstep,
      ⟨⟨hfj, .inr ⟨hripj, ?_⟩⟩, .inr ⟨hripj, hused⟩⟩⟩))
    show CacheInv (S.used j) (S.virt x'')
    rw [hused]
    exact CacheInv.emptyPe _ _
  · -- Not taken: falling through.
    have hnb : ¬ ((b != (cond == Cond.z)) = true) := by simp [hbn]
    rw [ite_eq_right hnb] at hpc
    rw [ite_eq_right hnb] at hrip2
    rw [← hpc] at hstep
    have hripC : x''.rip = addrAt S.ctx c3.pos := by
      (rw [hrip2, hrip, addrAt_add', hqT]) <;>
        simp only [codeSize, List.map_cons, List.map_nil, List.sum_cons, List.sum_nil,
          Nat.add_zero]
    exact Reach.steps hst (hdl_fallthrough hD hnop (by rw [hmem]; exact hfk.code') hbT hripC
      (.step hstep) (by show s.pc + 1 = k + 1; rw [hs]) (hfk.congr' hregs hxmm hmem) hcache)

set_option maxHeartbeats 1000000 in
/-- The `switch` shape's tail after the return: the jump through the table
(`Switch.switch_tail`) to entry `i`'s target (not a leading `arg`, `ArgsOk.untargeted`; the
cache cleared there, `CacheCleared.targets`). -/
theorem hdl_switch (hD : Decodes S code relocs rodata callSites dropped scopes mode) (H : Hyps S)
    {k pT pc i pE : Nat} {s s1 : R.RState}
    {x' : X86.State} {st' : OpSem.State} {ch : OpSem.Choice} {tb : BitVec 32}
    {es : List (BitVec 32)}
    (hlt : k < S.r.protos.size)
    (hdT : Dec (atPos S.body pT) pT (Switch.switchItems tb) pE) (hbT0 : Boundary S.rs pT)
    (hrip : x'.rip = addrAt S.ctx pT)
    (hes : ∀ i (hi : i < es.length), (atPos S.body (tb.toNat + 4 * i)).tableEntry tb = some es[i])
    (htb : tb.toNat < 2 ^ 31) (hbtb : Boundary S.rs tb.toNat) (hes31 : ∀ e ∈ es, e.toNat < 2 ^ 31)
    (hil : i < es.length) (hpe : posOf S.r pc = es[i].toNat)
    (htg : es[i].toNat ∈ S.r.protos[k].targets)
    (hrax : Handler.CtlIn (.index i) x')
    (hFI : ∀ pc, ¬ LeadArg S pc → FrameInvR S { s1 with pc, st := st' } x')
    (hstep : R.step S.c s ch = .ok (.step { s1 with pc, st := st' })) :
    Reach S.ctx S.E (SNextE S s) x' := by
  have hnl : ¬ LeadArg S pc := H.argsUntargeted hD k hlt _ htg pc hpe
  have hfi := hFI pc hnl
  have hlkT : LinkOkF S.ctx x'.mem (atPos S.body pT) S.rs S.c.mode := hfi.code'.atPos pT
  obtain ⟨hcaS, -, -⟩ := hlkT.dec hdT hbT0
  rw [hdl_fform_switch] at hcaS
  have htab : CodeAt S.ctx x'.mem (es.map (Item.tableEntry tb)) tb.toNat :=
    entries_codeAtF hfi.code' hes hbtb
  obtain ⟨x'', hst, hex, hrip'', -, -, hm, -, -⟩ :=
    Switch.switch_tail hcaS hrip htab hil hrax htb (hes31 _ (List.getElem_mem hil))
  have hregs := hdl_switch_regs hex
  have hrbp : x''.reg .rbp = x'.reg .rbp := by
    show x''.regs 5 = x'.regs 5
    exact hregs 5 (by decide) (by decide)
  have hrsp : x''.rsp = x'.rsp := by
    show x''.regs 4 = x'.regs 4
    exact hregs 4 (by decide) (by decide)
  have hsv : ∀ i, Saved S.c.mode.pe i → x''.regs i = x'.regs i := by
    intro i hi
    apply hregs <;> rcases hi with (rfl | rfl | rfl | rfl | rfl | rfl) | ⟨-, rfl | rfl⟩ <;> decide
  -- On the virtual states (`virt` reads only `rsp`).
  have hvr := setup_virt_regs_congr S (P := fun i => x''.regs i = x'.regs i) (fun _ h => h) hrsp
  have hfi'' := hdl_frameInv_regs hfi.1 (by rw [setup_virt_mem, setup_virt_mem]; exact hm)
    (hvr 5 hrbp) (by rw [setup_virt_rsp, setup_virt_rsp]; exact hrsp)
    (fun i hi => hvr i (hsv i hi)) hnl
  have hc := H.cacheTargets k hlt _ htg
  have hripP : x''.rip = addrAt S.ctx (posOf S.r pc) := by rw [hrip'', hpe]
  have hused : S.used pc = { pe := S.c.mode.pe } := by
    simp only [Setup.used, hpe, hc, ↓reduceIte]
  refine Reach.steps hst (.done (.inl ⟨_, .step hstep, ⟨⟨⟨hfi'', fun h => hrbp.trans (hfi.2 h)⟩,
    .inr ⟨hripP, ?_⟩⟩, .inr ⟨hripP, hused⟩⟩⟩))
  show CacheInv (S.used pc) (S.virt x'')
  rw [hused]
  exact CacheInv.emptyPe _ _

/-- The handler call's start in either frame form (for `hdl_call_reach`): the virtual state `xv`
the setup runs from (with a frame pointer the state itself; without one `rbp := rsp + F` and
`rip` shifted, `FForm.virtAt`), the real `rbp` `r` after the call, and the fetch of the setup
and the call (`handler_call_steps`, or `steps_of_run_last_fb`), and the way back from the
virtual relation after the return to the real one. -/
theorem hdl_vstart (hD : Decodes S code relocs rodata callSites dropped scopes mode) (H : Hyps S)
    {s : R.RState} {xr : X86.State} {p hat len n : Nat} {items : List Item}
    {args : List R.Arg} (hfR : FrameInvR S s xr) (hrip : xr.rip = addrAt S.ctx p)
    (hd : Dec (atPos S.body p) p items hat)
    (hcall : decodeItem (atPos (atPos S.body p) hat) = some (.call (.handler n), len))
    (hsetup : Handler.setupItems S.c.mode args = some items) (hbd : Boundary S.rs p) :
    ∃ (xv : X86.State) (r : BitVec 64), FrameInv S s xv ∧
      xv.rip + BitVec.ofNat 64 (codeSize (items ++ [Item.call (.handler n)])) =
        addrAt S.ctx (hat + len) ∧
      (S.c.mode.fpArg = false → r = xv.reg .rbp) ∧ SepAcrossHB S r (xv.reg .rbp) ∧
      (args.length ≤ (handlerRegs S.c.mode.pe).length → ∀ x2,
        execItems S.ctx (items ++ [Item.call (.handler n)]) xv = .ok x2 →
        x2.reg .rbp = xv.reg .rbp → Steps S.ctx xr (x2.setReg .rbp r)) ∧
      (S.c.mode.pe = true → ∀ x2,
        (∀ a, (∃ j, j < S.body.code.size ∧ a = addrAt S.ctx j) →
          ¬ HandlerStackArg.InStackArg xv.rsp a) →
        execItems S.ctx (items ++ [Item.call (.handler n)]) xv = .ok x2 →
        x2.reg .rbp = xv.reg .rbp → Steps S.ctx xr (x2.setReg .rbp r)) ∧
      (∀ (y : X86.State) (s' : R.RState), y.rsp = xv.rsp → y.reg .rbp = r →
        FrameInv S s' (y.setReg .rbp (xv.reg .rbp)) → FrameInvR S s' y) := by
  have hdc : Dec (atPos S.body p) p (items ++ [Item.call (.handler n)]) (hat + len) :=
    hd.append (Dec.single hcall)
  cases hsp : S.body.spFrame with
  | none =>
    -- The frame-pointer form: the virtual state is the real one.
    have hvx : S.virt xr = xr := S.virt_eq hsp
    have hfx : FrameInv S s xr := by have := hfR.1; rwa [hvx] at this
    have hlk : LinkOk S.ctx xr.mem (atPos S.body p) S.rs :=
      ⟨hfx.code.fields, hfx.code.sorted, hfx.code.loaded, hfx.code.small, hsp⟩
    obtain ⟨hca, hend, -⟩ := hlk.dec hdc hbd
    refine ⟨xr, xr.reg .rbp, hfx, ?_, fun _ => rfl, sepAcrossHB_self H _, ?_, ?_, ?_⟩
    · rw [hrip, addrAt_add', hend]
    · intro hreg x2 he hr2
      rw [← hr2, X86.State.setReg_reg_self]
      exact handler_call_steps hsetup hreg hca hrip he
    · intro hpe x2 hoff he hr2
      rw [← hr2, X86.State.setReg_reg_self]
      rcases HandlerStackArg.setupItems_length hsetup with hreg | ⟨-, h5⟩
      · exact handler_call_steps hsetup hreg hca hrip he
      · obtain ⟨a0, a1, a2, a3, a4, rfl⟩ := HandlerStackArg.eq_five h5
        exact handler_call_steps5 hpe H.linked hsetup hca hrip
          (fun a ha => hoff a (hdl_inCode_dec hlk hdc hbd a ha)) he
    · intro y s' _ hy2 hfi
      refine ⟨?_, rbpOk_of_sp hsp⟩
      rw [S.virt_eq hsp]
      rw [← hy2, X86.State.setReg_reg_self] at hfi
      exact hfi
  | some F =>
    -- Without a frame pointer: the setup runs on `virtAt`, fetched in its `spFrame` form.
    have hfpm : S.c.mode.framePointer = false := vt_nofp_of_sp hfR.1 hsp
    obtain ⟨hfa, hnpe⟩ := vt_fpArg_of_nofp hD.modeValid hfpm
    have hvx : ∀ y, S.virt y = FForm.virt (some F) y := fun y => by
      unfold Setup.virt Setup.fb; rw [hsp]
    have hsp' : (atPos S.body p).spFrame = some F := hsp
    obtain ⟨hca, hend, -⟩ := (hfR.1.code.atPos p).dec hdc hbd
    rw [hsp', setup_virt_mem] at hca
    rw [hsp'] at hend
    refine ⟨FForm.virtAt (some F) (items ++ [Item.call (.handler n)]) xr, xr.reg .rbp, ?_, ?_,
      fun h => (by rw [hfa] at h; cases h), sepAcrossHB_nofp H _ _, ?_,
      fun hpe => (by rw [hnpe] at hpe; cases hpe), ?_⟩
    · have := hfR.1
      rw [hvx] at this
      exact this.congr rfl rfl rfl
    · show xr.rip + FForm.delta (some F) (items ++ [Item.call (.handler n)]) +
        BitVec.ofNat 64 (codeSize (items ++ [Item.call (.handler n)])) = addrAt S.ctx (hat + len)
      rw [hrip, FForm.delta, BitVec.add_assoc, BitVec.sub_add_cancel, addrAt_add', hend]
    · intro hreg x2 he _
      have hok := hdl_setup_sp S.ctx F hfpm hsetup hreg
      have hcan : Canon ((items ++ [Item.call (.handler n)]).map (FForm.item (some F))) p :=
        handler_canon_of fun i hi => by
          obtain ⟨i0, hi0, rfl⟩ := List.mem_map.mp hi
          rcases List.mem_append.mp hi0 with hi0 | hi0
          · exact (hok i0 hi0).can
          · simp only [List.mem_singleton] at hi0
            subst hi0
            exact handler_call_canonical n
      exact steps_of_run_last_fb (fb := some F)
        (S := InCode S.ctx ((items ++ [Item.call (.handler n)]).map (FForm.item (some F))) p)
        (items := items) (j := Item.call (.handler n))
        (fun i hi => by
          rcases List.mem_append.mp hi with hi | hi
          · exact (hok i hi).rbp
          · simp only [List.mem_singleton] at hi
            subst hi
            exact rfl)
        (fun F' hF' => by
          obtain rfl := Option.some.inj hF'
          exact H.spDisp F hsp (atPos S.body p) rfl hsp p _ _ hdc)
        (fun i hi => (hok i hi).rip) (fun m h => by cases h)
        (fun i hi => (hok i hi).rsp) hcan hca hrip (fun _ h => h)
        (fetchRun_of_forall (fun i hi => ⟨(hok i hi).ft, (hok i hi).mkept⟩) _) he
    · intro y s' hy1 hy2 hfi
      refine ⟨?_, fun h => hy2.trans (hfR.2 h)⟩
      have e1 : (FForm.virtAt (some F) (items ++ [Item.call (.handler n)]) xr).reg .rbp =
          xr.rsp + F.setWidth 64 := X86.State.reg_setReg xr .rbp (xr.rsp + F.setWidth 64)
      have e2 : (FForm.virtAt (some F) (items ++ [Item.call (.handler n)]) xr).rsp = xr.rsp :=
        Handler.setRbp_rsp xr (xr.rsp + F.setWidth 64)
      rw [hvx y]
      show FrameInv S s' (y.setReg .rbp (y.rsp + F.setWidth 64))
      rw [hy1, e2, ← e1]
      exact hfi

set_option maxHeartbeats 1000000 in
set_option maxRecDepth 100000 in
/-- `resume` (`handler resume [x] trap`): R unwinds from `k` with the exception object in slot
`x` (`R.unwindAt`). `handler_call_steps` reaches the handler (`H.envOutside.handler`, an
environment step); each return is `H.resume`'s: at the landing pad `PadsLinked` gives
(`cleanupAt k = some (some pad, _)`, `posOf_lt_32`), `rsp` and the saved registers as before
the call, memory kept off runtime-owned bytes and the stack below `rsp` (`hdl_frameInv` keeps
`FrameInv`; `pad_not_leadArg`), the cache empty at the pad (`CacheCleared.pads`); no pad: no
return. `ResumeContract` also gives `rax` the slot's 8 bytes, but the proof discards it: R's
new `exception` (`asPtr` of the slot) is not related to `rax` here, nor by `FrameInv` (`Rel`
doesn't see `exception`), so the pad's `lpad` gets no relation to its `rax` (open). In either
frame form (`hdl_vstart`): the setup runs on the virtual state, the handler from the real one
(`ResumeContract` with the frame pointer explicit), the pad's relation on the virtual state. -/
theorem handler_resume'B (hD : Decodes S code relocs rodata callSites dropped scopes mode)
    (H : Hyps S) {k p : Nat} {a : Bool} {q : Proto} {cur c' : Cursor}
    (hP : ProtoFacts S k p q c' { pe := S.fr.mode.pe }) (hn : NoArg S.fr S.body p a cur)
    (hr : InsnRead S.fr S.ro cur q c') (hres : q.op = .resume) :
    BodySimBE S k p := by
  intro s xr hs hfR hrip _ hsafe
  have hcur := noArg_insn hn hr
  subst hcur
  obtain ⟨i, p1, ctr, hi, hio, hlt, hpk⟩ := protoFacts_insnOf hP
  have HA := hdl_apart hD H
  cases hr with
  | ret => simp only at hres; exact absurd hres (by decide)
  | unreachable => simp only at hres; exact absurd hres (by decide)
  | jmp => simp only at hres; exact absurd hres (by decide)
  | island => simp only at hres; exact absurd hres (by decide)
  | resume hrg => exact absurd hrg (by simp [Setup.fr])
  | dense hd =>
    obtain ⟨w, hw⟩ := handler_dense_op hd
    rw [hw] at hres; cases w <;> exact absurd hres (by decide)
  | @handler items hat n len nn op args t sites c'' hd hcall hnop hhh hsetup hthen =>
  simp only at hres
  subst hres
  obtain ⟨rfl, rfl⟩ := handler_thenSeq_resume hthen
  simp only [InsnOf] at hio
  obtain ⟨t', rfl, ht'⟩ := hio
  have := thenMap_trap ht'
  subst this
  rw [← hs] at hi
  cases hsc : (S.c.scopesAt s.pc).foldlM R.applyScope s with
  | error e =>
    exfalso
    obtain ⟨m, rfl⟩ := hsafe.1 {} e (step_scopes_err hi hsc)
    exact handler_scopes_err hsc m rfl
  | ok s1 =>
  have hst := Shapes.step_handler (ch := {}) hi hsc
  have hE : ∀ e, R.step S.c s {} = .error e → handler_NotNB e → False := fun e h1 h2 => by
    obtain ⟨m, hm⟩ := hsafe.1 {} e h1; exact h2 m hm
  cases hv : R.view S.c.mode S.c.ρ (.handler .resume args .trap) with
  | none =>
    exfalso
    obtain ⟨msg, hmsg⟩ : ∃ msg, R.stepView S.c s1 (.handler .resume args .trap) {} =
        .error (.illFormed msg) := by
      unfold R.stepView; simp only [hv]; exact ⟨_, rfl⟩
    exact hE _ (hst.trans hmsg) (handler_illFormed_notNB _)
  | some v =>
  obtain ⟨vals, hu, rfl⟩ := handler_view hv
  have hsv := hst
  unfold R.stepView at hsv
  simp only [hv] at hsv
  simp only [show (Full.Opcode.resume == Full.Opcode.resume) = true from by decide,
    ↓reduceIte] at hsv
  split at hsv
  rotate_left
  · exact (hE (.illFormed "resume's operands") (hsv.trans rfl) (handler_illFormed_notNB _)).elim
  rename_i off
  cases hrf : s1.st.readFrame off 8 with
  | error e =>
    rw [hrf] at hsv
    exact (hE e (hsv.trans rfl) (handler_readFrame_err hrf)).elim
  | ok bs =>
  cases hap : asPtr bs with
  | error e =>
    refine (hE e (by rw [hsv, hrf]; simp only [bind, Except.bind, hap]) ?_).elim
    unfold asPtr at hap
    split at hap
    · cases hap
    · simp only [OpSem.ub, throw, throwThe, MonadExceptOf.throw, Except.error.injEq] at hap
      subst hap
      intro m h; cases h
  | ok exc =>
  have hstep : R.step S.c s {} = unwindAt S.c s1 exc := by
    rw [hsv, hrf]; simp only [bind, Except.bind, hap]
  have hk1 := scopes_keeps _ hsc
  have hpc1 : s1.pc = k := hk1.pc.trans hs
  -- the x86 side: the setup and `call resume`, from the virtual state `xv` (`hdl_vstart`)
  obtain ⟨-, -, hbh⟩ := (hfR.code'.atPos p).dec hd hP.bound
  obtain ⟨-, hlen, -, -⟩ := decodeItem_itemAt_F ((hfR.code'.atPos p).atPos hat) hbh hcall
  have hlen5 : len = 5 := by
    have e : ∀ f : FForm, (FForm.item f (Item.call (.handler n))).size = 5 := fun f => by
      cases f <;> rfl
    rw [e] at hlen; exact hlen.symm
  subst hlen5
  obtain ⟨xv, r, hfx, hripE, hfpIn, -, hsteps4, -, hconv⟩ :=
    hdl_vstart hD H hfR hrip hd hcall hsetup hP.bound
  have hlo : S.lo.toNat + 8 ≤ xv.rsp.toNat := by have := hfx.room; omega
  have hreg : args.length ≤ (handlerRegs S.fr.mode.pe).length := by
    have h := resume_regs_le S.c.mode.fpArg S.c.mode.pe
    cases hl : Full.Opcode.resume.layout S.c.mode.fpArg S.c.mode.pe with
    | none => simp [R.unpack, hl] at hu
    | some l =>
      rw [hl] at h
      have : args.length = l.regs := by
        by_cases hne : args.length = l.regs
        · exact hne
        · simp [R.unpack, hl, hne] at hu
      rw [this]; exact h
  obtain ⟨x2, hx2, hat2, hargs2, hrsp2, hsaved2, hmem2, hret2⟩ :=
    handler_call_ret (lo := S.lo) (x := xv) S.ctx H.linked hnop hsetup hreg hlo
  have hrbp2 : x2.reg .rbp = xv.reg .rbp := hsaved2 5 (Island.saved_rbp _)
  have hsteps := hsteps4 hreg x2 hx2 hrbp2
  have hra : x2.mem.read64 x2.rsp = addrAt S.ctx (hat + 5) := by
    rw [hret2]; exact hripE
  have hsite : (hat, 5) ∈ S.r.protos[k].sites := by rw [hpk]; simp
  have hpl := (H.padsLinked hD hfx.code.small) k hlt (hat, 5) hsite (hat + 5) (by simp) (by simp)
  -- the handler runs from the real state `x2r`, its arguments read with `rbp := xv.reg .rbp`
  have hx2b : (x2.setReg .rbp r).setReg .rbp (xv.reg .rbp) = x2 := by
    rw [vt_setReg_setReg, ← hrbp2, X86.State.setReg_reg_self]
  have hx2rbp : (x2.setReg .rbp r).reg .rbp = r := X86.State.reg_setReg x2 .rbp r
  have hat2r : Handler.AtHandler S.ctx .resume (x2.setReg .rbp r) := hat2
  have hargs2r : Handler.ArgsIn S.c.ρ S.c.mode.pe ((x2.setReg .rbp r).setReg .rbp (xv.reg .rbp))
      (x2.setReg .rbp r) args := by
    rw [hx2b]
    refine ⟨fun i h1 h2 => ?_, fun h1 hpe => ?_⟩
    · rw [hargs2.1 i h1 h2, Handler.setRbp_reg x2 r _
        (Handler.handlerRegs_ne_rbp _ _ (List.getElem_mem h2))]
      rfl
    · obtain ⟨w, hw1, hw2, hw3⟩ := hargs2.2 h1 hpe
      exact ⟨w, hw1, hw2, by rw [Handler.setRbp_rsp]; exact hw3⟩
  have hout := H.envOutside.handler .resume (x2.setReg .rbp r) hat2r
  refine Reach.steps hsteps (.env hout fun x' hret => ?_)
  obtain ⟨hpad, -, hrsp', hsaved', hmem'⟩ := H.resume args off (x2.setReg .rbp r) x'
    (xv.reg .rbp) hu hat2r (fun hfa => hx2rbp.trans (hfpIn hfa)) hargs2r hret
  have hpad0 : S.padOf (x2.mem.read64 x2.rsp) = some x'.rip := by
    rw [← Handler.setRbp_rsp x2 r]; exact hpad
  rw [hra, hpl] at hpad0
  unfold unwindAt at hstep
  rw [hpc1] at hstep
  cases hcl : S.c.cleanupAt k with
  | none =>
    rw [hcl] at hstep
    exact (hE _ (hstep.trans rfl) (fun m h => by cases h)).elim
  | some pr =>
  obtain ⟨po, cat⟩ := pr
  cases po with
  | none => rw [hcl] at hpad0; cases hpad0
  | some pad =>
  rw [hcl] at hpad0 hstep
  have hpad' : x'.rip = addrAt S.ctx (posOf S.r pad) := by
    have h1 := (Option.some.inj hpad0).symm
    rw [h1, hdl_base_setWidth]
    obtain ⟨hpl', -⟩ := pad_lpad hD hcl
    have := Nat.lt_of_le_of_lt (posOf_le_size hD hpl') hfx.code.small
    simp only [pos32, BitVec.toNat_ofNat, Nat.mod_eq_of_lt this]
  have hnl := pad_not_leadArg hD hcl
  have hr1 := rrel_foldlM _ hfx.rrel hsc
  have hm1 := (memRel_foldlM _ (H.frameBounds.scope_size _) hfx.rrel hfx.mem hsc).2
  have hsep1 := (sep_foldlM _ (H.frameBounds.scopesIn s.pc) (H.frameBounds.window hfx.win)
    hfx.rrel hfx.sep hsc).2
  let s2 : R.RState := { s1 with pc := pad, st := { s1.st with exception := exc } }
  have hfi : FrameInv S s2 xv :=
    ⟨⟨⟨fun o h1 h2 b hb => hr1.rel.frame o h1 h2 b hb, hr1.rel.layout, hr1.rel.zeroSized⟩,
      hr1.rbp, ⟨hr1.wf.idLt, hr1.wf.idInj, hr1.wf.size, hr1.wf.disj⟩⟩, hm1, ⟨hsep1.own, hsep1.init, hsep1.dis, hsep1.space, hsep1.esc⟩, hk1.fp ▸ hfx.win, hk1.fp ▸ hfx.fpF, hfx.rsp, hfx.room,
      hfx.code, hfx.ro, fun h => absurd h hnl, hfx.frame,
      (H.slots_scopes hfx hsc).congr rfl (fun _ _ _ => rfl),
      ((hfx.esc.scopes hsc).of_not hnl).congr rfl⟩
  -- back on the virtual state: `y` is `x'` with `rbp := xv.reg .rbp`
  have hx'rbp : x'.reg .rbp = r := by
    show x'.regs 5 = r
    rw [hsaved' 5 (Island.saved_rbp _)]
    exact hx2rbp
  have hx'rsp : x'.rsp = xv.rsp := by
    rw [hrsp', Handler.setRbp_rsp, hrsp2]; exact BitVec.sub_add_cancel _ _
  have hsvY : ∀ i, Saved S.c.mode.pe i → (x'.setReg .rbp (xv.reg .rbp)).regs i = xv.regs i := by
    intro i hi
    by_cases h5 : i = 5
    · subst h5; exact X86.State.reg_setReg x' .rbp _
    · have e1 : (x'.setReg .rbp (xv.reg .rbp)).regs i = x'.regs i := by
        show (if i = Reg.rbp.idx then _ else x'.regs i) = x'.regs i
        rw [if_neg (fun h => h5 (h.trans (by decide)))]
      have e2 : (x2.setReg .rbp r).regs i = x2.regs i := by
        show (if i = Reg.rbp.idx then _ else x2.regs i) = x2.regs i
        rw [if_neg (fun h => h5 (h.trans (by decide)))]
      rw [e1, hsaved' i hi, e2, hsaved2 i hi]
  have hag : Counter.Agree S.Owned S.lo xv (x'.setReg .rbp (xv.reg .rbp)) := by
    refine ⟨by rw [Handler.setRbp_rsp]; exact hx'rsp, fun i hi => hsvY i (Or.inl hi),
      fun a ho hst => ?_⟩
    show x'.mem a = xv.mem a
    rw [hmem' a ho ?_]
    · exact hmem2 a hst
    intro ⟨h1, h2⟩
    apply hst
    refine ⟨h1, ?_⟩
    rw [Handler.setRbp_rsp, hrsp2, BitVec.toNat_sub] at h2
    have := xv.rsp.isLt
    simp at h2
    omega
  have hfin := hdl_frameInv H HA hfi hag hsvY hnl
  have hstep' : R.step S.c s {} = .ok (.step s2) := hstep.trans rfl
  refine .done (.inl ⟨s2, .step hstep',
    ⟨⟨hconv x' s2 hx'rsp hx'rbp hfin, .inr ⟨hpad', ?_⟩⟩, .inr ⟨hpad', ?_⟩⟩⟩)
  · show CacheInv (S.used pad) (S.virt x')
    rw [(H.cacheCleared hD).pads k pad cat hcl]
    exact CacheInv.emptyPe _ _
  · show S.used pad = { pe := S.c.mode.pe }
    exact (H.cacheCleared hD).pads k pad cat hcl

theorem handler_resume' (hD : Decodes S code relocs rodata callSites dropped scopes mode)
    (H : Hyps S) {k p : Nat} {a : Bool} {q : Proto} {cur c' : Cursor}
    (hP : ProtoFacts S k p q c' { pe := S.fr.mode.pe }) (hn : NoArg S.fr S.body p a cur)
    (hr : InsnRead S.fr S.ro cur q c') (hres : q.op = .resume) :
    BodySim S k p (S.used k) :=
  BodySimB.used (handler_resume'B hD H hP hn hr hres).toB

set_option maxHeartbeats 1000000 in
set_option maxRecDepth 100000 in
/-- A handler call other than `resume` (see `bodySim_handler'`). -/
theorem handler_general'B (hD : Decodes S code relocs rodata callSites dropped scopes mode)
    (H : Hyps S) {k p : Nat} {a : Bool} {q : Proto} {cur c' : Cursor}
    (hP : ProtoFacts S k p q c' { pe := S.fr.mode.pe }) (hn : NoArg S.fr S.body p a cur)
    (hr : InsnRead S.fr S.ro cur q c') (hh : q.handler ≠ none) (hres : q.op ≠ .resume)
    (hnd : ∀ c'', (denseSwitch S.fr).run cur ≠ .ok (some q, c''))
    (htable : HdlTables S) :
    BodySimBE S k p := by
  intro s x hs hfR hrip hbx hsafe
  have hcur := noArg_insn hn hr
  subst hcur
  obtain ⟨i, p1, ctr, hi, hio, hlt, hpk⟩ := protoFacts_insnOf hP
  cases hr with
  | ret => exact (hh rfl).elim
  | unreachable => exact (hh rfl).elim
  | jmp => exact (hh rfl).elim
  | island => exact (hh rfl).elim
  | resume => exact (hres rfl).elim
  | dense hd => exact (hnd _ hd).elim
  | @handler items hat n len nn op args t sites c'' hd hcall hnop hhh hsetup hthen =>
  have hres' : op ≠ .resume := hres
  have hun : op ≠ .unreachable := by rintro rfl; simp [noHandler] at hhh
  simp only [InsnOf] at hio
  obtain ⟨t', rfl, ht'⟩ := hio
  rw [← hs] at hi
  obtain ⟨s1, vals, hsc, hu, hno, hsucc⟩ := handler_rside hi hsafe hres' hun
  obtain ⟨-, -, hbe⟩ := (hfR.code'.atPos p).dec (hd.append (Dec.single hcall)) hP.bound
  have hbe' : Boundary S.rs (hat + len) := hbe
  obtain ⟨xv, r, hfx, hripE, hfpIn, hsepB, hsteps4, hsteps5, hconv⟩ :=
    hdl_vstart hD H hfR hrip hd hcall hsetup hP.bound
  refine hdl_call_reach hD H hfx hbx.choose_spec hnop hhh hsetup hi
    hsc hu hno hripE hfpIn hsepB hsteps4 hsteps5 ?_
  intro x' ch ctl st' hop hctl hripT hrsp' hrbp' hFI0
  obtain ⟨st'', pc, hcl, hpc, hstep⟩ := hsucc ch ctl st' hop
  have hFI : ∀ pc, ¬ LeadArg S pc → FrameInvR S { s1 with pc, st := st'' } x' :=
    fun pc hnl => hconv x' _ hrsp' hrbp' (hFI0 st'' hcl pc hnl)
  cases thenSeq_read hthen with
  | next hsh =>
    have ht0 := thenMap_next ht'
    subst ht0
    have hpc1 := hdl_succ_next hpc
    rw [hpc1] at hstep
    have harg : op ≠ .arg := by
      rintro rfl
      rw [hdl_arg_shape] at hsh
      rcases hsh with h | h <;> cases h
    have hnl : ¬ LeadArg S (s.pc + 1) := by rw [hs]; exact hdl_next_notLead hD hP harg
    have hfi := hFI (s.pc + 1) hnl
    have hb1 : S.c.inRegion (k + 1) = false := hD.fallBody hP.body (by rw [← hs]; exact hi)
      (by rcases hsh with h | h <;> simp [RSucc.insnFalls, h])
    exact hdl_fallthrough hD (pC := hat + len) (hP.nop hb1) hfi.code' hbe' hripT (.step hstep)
      (by show s.pc + 1 = k + 1; rw [hs]) hfi (hP.cache hb1)
  | br hsh hcond hdecT hc3 =>
    obtain ⟨j, rfl, hj⟩ := thenMap_branch ht'
    obtain ⟨b, rfl, hpc'⟩ := hdl_succ_branch hpc
    have harg : op ≠ .arg := by
      rintro rfl
      rw [hdl_arg_shape] at hsh
      cases hsh
    exact hdl_br hD H (pT := hat + len) hs hlt
      (by rw [hpk]; simp [Proto.targets, R.Then.targets]) hj hcond hdecT hbe' hripT hctl hFI
      hpc' hstep (hdl_next_notLead hD hP harg)
      (hP.nop (hD.fallBody hP.body (by rw [← hs]; exact hi) (by simp [RSucc.insnFalls, hsh])))
      (hP.cache (hD.fallBody hP.body (by rw [← hs]; exact hi) (by simp [RSucc.insnFalls, hsh])))
  | switch hsh htr =>
    obtain ⟨tb, pE, es, hdT, rfl, hes, -⟩ := table_read htr
    obtain ⟨rs', rfl, hmap⟩ := thenMap_table ht'
    obtain ⟨i, rfl, hget⟩ := hdl_succ_table hpc
    obtain ⟨hil, -⟩ := List.getElem?_eq_some_iff.1 hget
    have hlen : rs'.length = es.length := by
      have := congrArg List.length hmap
      simpa using this
    have hil' : i < es.length := hlen ▸ hil
    have hpe : posOf S.r pc = es[i].toNat := by
      have h1 : (rs'.map (posOf S.r))[i]? = (es.map (·.toNat))[i]? := by rw [hmap]
      rw [List.getElem?_map, List.getElem?_map, hget, List.getElem?_eq_getElem hil'] at h1
      simpa using h1
    obtain ⟨htb, hbtb, hes31⟩ :=
      htable (atPos (atPos S.body p) (hat + len)) tb pE es k rfl rfl rfl hdT hes
        (List.ne_nil_of_length_pos (by omega)) hlt (fun e he => by
          rw [hpk]
          simp [Proto.targets, R.Then.targets] <;> exact ⟨e, he, rfl⟩)
    exact hdl_switch hD H (pT := hat + len) hlt hdT hbe' hripT hes htb hbtb hes31 hil' hpe
      (by
        rw [hpk]
        simp [Proto.targets, R.Then.targets] <;> exact ⟨es[i], List.getElem_mem hil', rfl⟩)
      hctl hFI hstep
  | trap hsh hdt hc3 =>
    have ht0 := thenMap_trap ht'
    subst ht0
    exact (hdl_succ_trap hpc).elim

theorem handler_general' (hD : Decodes S code relocs rodata callSites dropped scopes mode)
    (H : Hyps S) {k p : Nat} {a : Bool} {q : Proto} {cur c' : Cursor}
    (hP : ProtoFacts S k p q c' { pe := S.fr.mode.pe }) (hn : NoArg S.fr S.body p a cur)
    (hr : InsnRead S.fr S.ro cur q c') (hh : q.handler ≠ none) (hres : q.op ≠ .resume)
    (hnd : ∀ c'', (denseSwitch S.fr).run cur ≠ .ok (some q, c''))
    (htable : HdlTables S) :
    BodySim S k p (S.used k) :=
  BodySimB.used (handler_general'B hD H hP hn hr hh hres hnd htable).toB

set_option maxHeartbeats 1000000 in
set_option maxRecDepth 100000 in
/-- T2.4: `resume`'s handler call on PE never comes back (`Hyps.resumePe`): from the setup
steps to the handler's entry (as `handler_resume'B`) the environment runs (`EnvOutside.handler`)
and no return is possible, so any post-condition holds (at a PE cleanup site, too:
`ProtoFactsN`). -/
theorem handler_resume_pe (hD : Decodes S code relocs rodata callSites dropped scopes mode)
    (H : Hyps S) (hpe : S.c.mode.pe = true) {k p : Nat} {a : Bool} {q : Proto} {cur c' : Cursor}
    (hP : ProtoFactsN S k p q c' { pe := S.fr.mode.pe }) (hn : NoArg S.fr S.body p a cur)
    (hr : InsnRead S.fr S.ro cur q c') (hres : q.op = .resume) :
    ∀ s x, s.pc = k → FrameInv S s x → x.rip = addrAt S.ctx p → RSafe S.Safe S.c s →
      Reach S.ctx S.E (fun _ => False) x := by
  intro s xr hs hfx hrip hsafe
  have hfp := vt_fp_of_pe hD.modeValid hpe
  have hfR : FrameInvR S s xr := (frameInvR_iff hfp).2 hfx
  have hcur := noArg_insn hn hr
  subst hcur
  obtain ⟨i, hi, hio0⟩ := hP.insn
  have hlt := hP.lt
  obtain ⟨p1, ctr, hpq⟩ := hP.proto
  have hpk : S.r.protos[k] = { q with pos := p1, counter := ctr } := by
    rw [Array.getElem?_eq_some_iff] at hpq
    exact hpq.2
  have hio : InsnOf (posOf S.r) { q with pos := p1, counter := ctr } i := hpk ▸ hio0 hlt
  cases hr with
  | ret => simp only at hres; exact absurd hres (by decide)
  | unreachable => simp only at hres; exact absurd hres (by decide)
  | jmp => simp only at hres; exact absurd hres (by decide)
  | island => simp only at hres; exact absurd hres (by decide)
  | resume hrg => exact absurd hrg (by simp [Setup.fr])
  | dense hd =>
    obtain ⟨w, hw⟩ := handler_dense_op hd
    rw [hw] at hres; cases w <;> exact absurd hres (by decide)
  | @handler items hat n len nn op args t sites c'' hd hcall hnop hhh hsetup hthen =>
  simp only at hres
  subst hres
  obtain ⟨rfl, rfl⟩ := handler_thenSeq_resume hthen
  simp only [InsnOf] at hio
  obtain ⟨t', rfl, ht'⟩ := hio
  have := thenMap_trap ht'
  subst this
  rw [← hs] at hi
  -- `args` fits the handler registers (R's view of the instruction, `R.unpack`)
  cases hsc : (S.c.scopesAt s.pc).foldlM R.applyScope s with
  | error e =>
    exfalso
    obtain ⟨m, rfl⟩ := hsafe.1 {} e (step_scopes_err hi hsc)
    exact handler_scopes_err hsc m rfl
  | ok s1 =>
  have hst := Shapes.step_handler (ch := {}) hi hsc
  have hE : ∀ e, R.step S.c s {} = .error e → handler_NotNB e → False := fun e h1 h2 => by
    obtain ⟨m, hm⟩ := hsafe.1 {} e h1; exact h2 m hm
  cases hv : R.view S.c.mode S.c.ρ (.handler .resume args .trap) with
  | none =>
    exfalso
    obtain ⟨msg, hmsg⟩ : ∃ msg, R.stepView S.c s1 (.handler .resume args .trap) {} =
        .error (.illFormed msg) := by
      unfold R.stepView; simp only [hv]; exact ⟨_, rfl⟩
    exact hE _ (hst.trans hmsg) (handler_illFormed_notNB _)
  | some v =>
  obtain ⟨vals, hu, rfl⟩ := handler_view hv
  -- the x86 side: the setup and `call resume` (as `handler_resume'B`)
  obtain ⟨-, -, hbh⟩ := (hfR.code'.atPos p).dec hd hP.bound
  obtain ⟨-, hlen, -, -⟩ := decodeItem_itemAt_F ((hfR.code'.atPos p).atPos hat) hbh hcall
  have hlen5 : len = 5 := by
    have e : ∀ f : FForm, (FForm.item f (Item.call (.handler n))).size = 5 := fun f => by
      cases f <;> rfl
    rw [e] at hlen; exact hlen.symm
  subst hlen5
  obtain ⟨xv, r, hfx', -, -, -, hsteps4, -, -⟩ :=
    hdl_vstart hD H hfR hrip hd hcall hsetup hP.bound
  have hlo : S.lo.toNat + 8 ≤ xv.rsp.toNat := by have := hfx'.room; omega
  have hreg : args.length ≤ (handlerRegs S.fr.mode.pe).length := by
    have h := resume_regs_le S.c.mode.fpArg S.c.mode.pe
    cases hl : Full.Opcode.resume.layout S.c.mode.fpArg S.c.mode.pe with
    | none => simp [R.unpack, hl] at hu
    | some l =>
      rw [hl] at h
      have : args.length = l.regs := by
        by_cases hne : args.length = l.regs
        · exact hne
        · simp [R.unpack, hl, hne] at hu
      rw [this]; exact h
  obtain ⟨x2, hx2, hat2, -, -, hsaved2, -, -⟩ :=
    handler_call_ret (lo := S.lo) (x := xv) S.ctx H.linked hnop hsetup hreg hlo
  have hrbp2 : x2.reg .rbp = xv.reg .rbp := hsaved2 5 (Island.saved_rbp _)
  have hsteps := hsteps4 hreg x2 hx2 hrbp2
  have hat2r : Handler.AtHandler S.ctx .resume (x2.setReg .rbp r) := hat2
  -- the handler never returns on PE (`Hyps.resumePe`)
  exact Reach.steps hsteps (.env (H.envOutside.handler .resume (x2.setReg .rbp r) hat2r)
    fun x' hret => (H.resumePe hpe _ x' hat2r hret).elim)

/-- `bodySim_handler'`: `resume` by `handler_resume'`, every other handler call by
`handler_general'` (`noArg_insn`, `InsnRead.handler` as in `link_handler`; `handler_rside` for
the R side under `RSafe`; `hdl_call_reach` for the setup, `call h` and the return under
`H.handler` and `SepAcross.handler`; then the shape's tail: `hdl_fallthrough` for `op`/`lpad`,
`hdl_br`, `hdl_switch`, and `trap` excluded by `RSafe`). Beyond `Hyps`: the decoder's read isn't
an inline dense switch (`hnd`, as `link_handler`'s: the dispatch has it from `insn_split`); the
switch tables' positions (`htable`, from the decoding and `tablesCheck`:
`DecodeLink.Tables.hdlTables_of_check`). -/
theorem bodySim_handler'B (hD : Decodes S code relocs rodata callSites dropped scopes mode)
    (H : Hyps S) {k p : Nat} {a : Bool} {q : Proto} {cur c' : Cursor}
    (hP : ProtoFacts S k p q c' { pe := S.fr.mode.pe }) (hn : NoArg S.fr S.body p a cur)
    (hr : InsnRead S.fr S.ro cur q c') (hh : q.handler ≠ none)
    (hnd : ∀ c'', (denseSwitch S.fr).run cur ≠ .ok (some q, c''))
    (htable : HdlTables S) :
    BodySimBE S k p := by
  by_cases hres : q.op = .resume
  · exact handler_resume'B hD H hP hn hr hres
  · exact handler_general'B hD H hP hn hr hh hres hnd htable

theorem bodySim_handler' (hD : Decodes S code relocs rodata callSites dropped scopes mode)
    (H : Hyps S) {k p : Nat} {a : Bool} {q : Proto} {cur c' : Cursor}
    (hP : ProtoFacts S k p q c' { pe := S.fr.mode.pe }) (hn : NoArg S.fr S.body p a cur)
    (hr : InsnRead S.fr S.ro cur q c') (hh : q.handler ≠ none)
    (hnd : ∀ c'', (denseSwitch S.fr).run cur ≠ .ok (some q, c''))
    (htable : HdlTables S) :
    BodySim S k p (S.used k) :=
  BodySimB.used (bodySim_handler'B hD H hP hn hr hh hnd htable).toB

end Insn

end Ryo.Proofs.DecodeSound
