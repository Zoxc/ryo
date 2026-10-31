import Ryo.Proofs.DecodeSound.Basic
import Ryo.Proofs.NoArgCursor
import Ryo.Proofs.DSWork.Island
import Ryo.Proofs.OpFacts

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
the scopes succeed, the arguments unpack, `opSem` has no UB, and each of its results is an R
step to `Then.succ`'s successor. -/
theorem handler_rside {Safe : R.Query → Prop} {c : R.Code} {s : R.RState} {h : Full.Opcode}
    {args : List R.Arg} {t : R.Then Nat} (hi : c.d.insns[s.pc]? = some (.handler h args t))
    (hsafe : RSafe Safe c s) (hres : h ≠ .resume) (hun : h ≠ .unreachable) :
    ∃ s1 vals, (c.scopesAt s.pc).foldlM R.applyScope s = .ok s1 ∧
      R.unpack c.ρ h c.mode args = some vals ∧ Handler.NoUB h vals s1.st ∧
      ∀ ch ctl st', opSem h vals s1.st ch = .ok (ctl, st') → ∃ pc, t.succ s.pc ctl = some pc ∧
        R.step c s ch = .ok (.step { s1 with pc, st := st' }) := by
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
      · cases hp : t.succ s.pc ctl with
        | none =>
          exfalso
          obtain ⟨msg, hmsg⟩ : ∃ msg, R.stepView c s1 (.handler h args t) ch =
              .error (.illFormed msg) := by
            unfold R.stepView
            simp only [hv, bind, Except.bind, beq_iff_eq, hres, hun, ↓reduceIte, hop, hpc, hp]
            exact ⟨_, rfl⟩
          exact hE ch _ ((hst ch).trans hmsg) (handler_illFormed_notNB _)
        | some pc =>
          exact ⟨pc, rfl, (hst ch).trans
            (Shapes.stepView_succ hv hres hun hop (by rw [hpc]; exact hp))⟩

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

/-- A setup item (frame-pointer form): canonical everywhere, falling through, memory kept. -/
theorem handler_argItem_ok (ctx : Ctx) {mode : Ryo.Obj.Mode} (hfp : mode.framePointer = true)
    {r : X86.Reg} {a : R.Arg} {it : Item} (h : Handler.argItem mode r a = some it) :
    (∀ p, it.Canonical p) ∧ it.FallsThrough ctx ∧ it.MemKept ctx := by
  have gen : ∀ it : Item, (∀ b e, it ≠ .tableEntry b e) → (∀ p, it.wf p = true) →
      (∀ s s', it.exec ctx s = .ok s' → s'.rip = s.rip + BitVec.ofNat 64 it.size ∧
        s'.mem = s.mem) →
      (∀ p, it.Canonical p) ∧ it.FallsThrough ctx ∧ it.MemKept ctx :=
    fun it ht hw he => ⟨fun p => ⟨ht, .inl (hw _)⟩, fun s s' h => (he s s' h).1,
      fun s s' h => (he s s' h).2⟩
  cases a with
  | fp =>
    simp only [Handler.argItem, fpItem, hfp, ↓reduceIte, Option.some.injEq] at h; subst h
    exact gen _ (fun _ _ h => nomatch h) (fun _ => rfl) fun s s' he => by
      cases Switch.except_ok_inj he; exact ⟨rfl, rfl⟩
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

theorem handler_setup_ok (ctx : Ctx) {mode : Ryo.Obj.Mode} (hfp : mode.framePointer = true)
    {args : List R.Arg} {items : List Item} (hs : Handler.setupItems mode args = some items)
    (hreg : args.length ≤ (handlerRegs mode.pe).length) :
    ∀ it ∈ items, (∀ p, it.Canonical p) ∧ it.FallsThrough ctx ∧ it.MemKept ctx := by
  intro it hit
  rw [Handler.setupItems_regs hreg] at hs
  obtain ⟨⟨a, r⟩, -, hf⟩ := handler_mapM_mem hs it hit
  exact handler_argItem_ok ctx hfp hf

theorem handler_canon_of : ∀ {l : List Item} {pos : Nat}, (∀ i ∈ l, ∀ p, i.Canonical p) →
    Canon l pos
  | [], _, _ => trivial
  | i :: l, pos, h => ⟨h i (by simp) pos, handler_canon_of fun j hj => h j (by simp [hj])⟩

theorem handler_call_canonical (n p : Nat) : (Item.call (.handler n)).Canonical p := by
  unfold Item.Canonical
  exact ⟨fun _ _ h => (nomatch h), Or.inl rfl⟩

/-- The setup and the call, fetched from memory at `p`. -/
theorem handler_call_steps {ctx : Ctx} {mode : Ryo.Obj.Mode} (hfp : mode.framePointer = true)
    {args : List R.Arg} {items : List Item} (hs : Handler.setupItems mode args = some items)
    (hreg : args.length ≤ (handlerRegs mode.pe).length) {n p : Nat} {x x2 : X86.State} (hc : CodeAt ctx x.mem (items ++ [Item.call (.handler n)]) p)
    (hrip : x.rip = addrAt ctx p)
    (he : execItems ctx (items ++ [Item.call (.handler n)]) x = .ok x2) : Steps ctx x x2 := by
  have hok := handler_setup_ok ctx hfp hs hreg
  have hcan : Canon (items ++ [Item.call (.handler n)]) p :=
    handler_canon_of fun i hi => by
      rcases List.mem_append.mp hi with hi | hi
      · exact (hok i hi).1
      · simp only [List.mem_singleton] at hi; subst hi; exact handler_call_canonical n
  exact steps_of_run_last (S := InCode ctx (items ++ [Item.call (.handler n)]) p) hcan hc hrip
    (fun _ h => h) (fetchRun_of_forall (fun i hi => (hok i hi).2) x) he

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

/-- The numbers behind a boundary's frame: `rbp = fp`, `rsp = fp - F`, the entry `rsp = fp + 8`. -/
theorem hdl_nums (H : Hyps S) {s : R.RState} {x : X86.State} (hf : FrameInv S s x) :
    (x.reg .rbp).toNat = s.fp ∧ x.rsp.toNat = s.fp - S.F ∧ S.x0.rsp.toNat = s.fp + 8 ∧
      s.fp + 16 ≤ 2 ^ 64 ∧ S.F ≤ s.fp ∧ (S.K : Int) ≤ 2 ^ 31 ∧ 16 ≤ S.K := by
  have hK := H.argSizeK
  have hKl := H.frameBounds.K_le
  have hwin := hf.win
  have hfp := hf.fpF
  have hb := hf.rrel.rbp
  have hlt : s.fp < 2 ^ 64 := by omega
  have hrb : (x.reg .rbp).toNat = s.fp := by rw [hb, BitVec.toNat_ofNat, Nat.mod_eq_of_lt hlt]
  refine ⟨hrb, ?_, ?_, by omega, hfp, hKl, by omega⟩
  · rw [hf.rsp, BitVec.toNat_sub, hrb, BitVec.toNat_ofNat]
    have : S.F < 2 ^ 64 := by omega
    rw [Nat.mod_eq_of_lt this]; omega
  · have e : S.x0.rsp = x.reg .rbp + 8 := by have := hf.frame.rbp; bv_omega
    rw [e, BitVec.toNat_add, hrb]; simp; omega

theorem hdl_rsp_le (H : Hyps S) {s : R.RState} {x : X86.State} (hf : FrameInv S s x) :
    x.rsp.toNat ≤ S.x0.rsp.toNat := by
  obtain ⟨-, h2, h3, -⟩ := hdl_nums H hf; omega

theorem hdl_inStack_lift (H : Hyps S) {s : R.RState} {x : X86.State} (hf : FrameInv S s x)
    {a : BitVec 64} (h : ¬ InStack S.lo S.x0.rsp a) : ¬ InStack S.lo x.rsp a := by
  have := hdl_rsp_le H hf
  intro ⟨h1, h2⟩; exact h ⟨h1, by omega⟩

/-- The frame window is apart from what the handler call may write (`S.Owned`, the stack below
`rsp`). -/
theorem hdl_window_apart (H : Hyps S) (HC : HdlApart S) {s : R.RState} {x : X86.State}
    (hf : FrameInv S s x) {o : Int} (h1 : -(S.F : Int) ≤ o) (h2 : o < S.K) :
    ¬ S.Owned (fpAddr x o) ∧ ¬ InStack S.lo x.rsp (fpAddr x o) := by
  refine ⟨HC.window s x hf o h1 h2, fun ⟨_, hs⟩ => ?_⟩
  obtain ⟨hrb, hrsp, -, hw, hF, hKl, -⟩ := hdl_nums H hf
  have hwin := hf.win
  rw [hrsp] at hs
  simp only [fpAddr, BitVec.toNat_add, hrb, BitVec.toNat_ofInt] at hs
  omega

/-- `m` agrees with `x`'s memory outside what the handler call may write (`S.Owned`, and the
stack in `[S.lo, rsp)`). -/
abbrev hdl_Keeps (S : Setup) (x : X86.State) (m : Mem) : Prop :=
  ∀ a, ¬ S.Owned a → ¬ InStack S.lo x.rsp a → m a = x.mem a

theorem hdl_linkOk (H : Hyps S) (HC : HdlApart S) {s : R.RState} {x : X86.State}
    (hf : FrameInv S s x) {m : Mem} (hm : hdl_Keeps S x m) : LinkOk S.ctx m S.body S.rs := by
  have hc : ∀ j, j < S.body.code.size → m (addrAt S.ctx j) = x.mem (addrAt S.ctx j) := by
    intro j hj
    obtain ⟨ho, hst, -⟩ := H.codeApart (addrAt S.ctx j) (.inl ⟨j, hj, rfl⟩)
    exact hm _ ho (hdl_inStack_lift H hf hst)
  obtain ⟨hfl, hso, ⟨hl1, hl2⟩, hsm, hfp⟩ := hf.code
  refine ⟨hfl, hso, ⟨fun j hj hr => ?_, fun r hr k hk => ?_⟩, hsm, hfp⟩
  · rw [hc j hj]; exact hl1 j hj hr
  · rw [hc _ (by have := HC.relocs r hr; omega)]; exact hl2 r hr k hk

theorem hdl_roLoaded (H : Hyps S) {s : R.RState} {x : X86.State}
    (hf : FrameInv S s x) {m : Mem} (hm : hdl_Keeps S x m) : RoLoaded S.ctx m S.ro := by
  obtain ⟨base, h1, h2⟩ := hf.ro
  refine ⟨base, h1, fun j hj => ?_⟩
  obtain ⟨ho, hst, -⟩ := H.codeApart (base + BitVec.ofNat 64 j) (.inr ⟨j, hj, (h1 j).symm⟩)
  rw [hm _ ho (hdl_inStack_lift H hf hst)]; exact h2 j hj

theorem hdl_read64 (H : Hyps S) (HC : HdlApart S) {s : R.RState} {x : X86.State}
    (hf : FrameInv S s x) {m : Mem} (hm : hdl_Keeps S x m) {o : Int}
    (h1 : -(S.F : Int) ≤ o) (h2 : o + 8 ≤ S.K) : m.read64 (fpAddr x o) = x.mem.read64 (fpAddr x o) := by
  unfold Mem.read64; congr 1
  apply readNat_congr
  intro i hi
  rw [← fpAddr_add]
  obtain ⟨a1, a2⟩ := hdl_window_apart H HC hf (o := o + i) (by omega) (by omega)
  exact hm _ a1 a2

/-- A frame byte `opSem` can read and that is initialized is apart from the handler call's
writes (`S.Owned`, the stack below `rsp`). -/
theorem hdl_byte_apart (H : Hyps S) (HC : HdlApart S) {s : R.RState} {x : X86.State}
    (hf : FrameInv S s x) {o : Int} {b : AbstractByte} (hb : s.st.byteAt o = .ok b)
    (hu : b ≠ .uninit) :
    ¬ S.Owned (fpAddr x o) ∧ ¬ InStack S.lo x.rsp (fpAddr x o) := by
  unfold OpSem.State.byteAt at hb
  split at hb
  · rename_i hn
    have hb' : s.st.frame o = b := by simpa [pure, Except.pure] using hb
    obtain ⟨i1, i2⟩ := hf.sep.init o hn (by rw [hb']; exact hu)
    exact hdl_window_apart H HC hf i1 i2
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
          refine HC.allocs s x hf _ ⟨e.id, a, hg, by simpa using hlive, ?_⟩
          rw [haddr, hdl_add_sub_left, BitVec.toNat_ofNat]
          simp only [Allocation.size] at *
          omega
        · cases hb
    · cases hb

/-- `FrameInv` survives a state that agrees with `x` (`Counter.Agree`), at an instruction past
the leading `arg`s. -/
theorem hdl_frameInv (H : Hyps S) (HC : HdlApart S) {s : R.RState} {x y : X86.State}
    (hf : FrameInv S s x) (hag : Counter.Agree S.Owned S.lo x y)
    (hsv : ∀ i, Saved S.c.mode.pe i → y.regs i = x.regs i) (ha : ¬ LeadArg S s.pc) :
    FrameInv S s y := by
  have hrbp : y.reg .rbp = x.reg .rbp := hag.2.1 5 (Or.inr (Or.inl rfl))
  have hfp : ∀ o, fpAddr y o = fpAddr x o := fun o => by simp [fpAddr, hrbp]
  have hm : hdl_Keeps S x y.mem := hag.2.2
  obtain ⟨hrb, hrsp, -, hw, hF, hKl, hK16⟩ := hdl_nums H hf
  refine ⟨⟨⟨fun o h1 h2 b hb => ?_, fun e he a h => ?_, fun p hp => ?_⟩, hrbp.trans hf.rrel.rbp,
    hf.rrel.wf⟩, fun id a hg hl i hi => ?_, hf.sep.congr hrbp, hf.win, hf.fpF,
    by rw [hag.1, hrbp]; exact hf.rsp, by rw [hag.1]; exact hf.room, hdl_linkOk H HC hf hm,
    hdl_roLoaded H hf hm, fun h => absurd h ha, ?_⟩
  · have hr := hf.rrel.rel.frame o h1 h2 b hb
    rw [hfp]
    cases b with
    | uninit => trivial
    | init v p =>
      obtain ⟨a1, a2⟩ := hdl_byte_apart H HC hf hb (by simp)
      rw [hm _ a1 a2]; exact hr
  · rw [hfp]; exact hf.rrel.rel.layout e he a h
  · rw [hfp]; exact hf.rrel.rel.zeroSized p hp
  · have hr := hf.mem id a hg hl i hi
    have hsp := hf.sep.space id a hg hl
    obtain ⟨a1, a2⟩ := HC.allocs s x hf (BitVec.ofNat 64 (a.addr + i)) ⟨id, a, hg, hl, by
      rw [BitVec.ofNat_add, hdl_add_sub_left, BitVec.toNat_ofNat]
      simp only [Allocation.size] at *
      omega⟩
    rw [hm _ a1 a2]; exact hr
  · obtain ⟨f1, f2, f3, f5⟩ := hf.frame
    have e8 : x.reg .rbp + 8 = fpAddr x 8 := rfl
    have e0 : x.reg .rbp = fpAddr x 0 := by simp [fpAddr]
    refine ⟨by rw [hrbp]; exact f1, ?_, ?_, fun i hi h5 => by
      rw [hsv i hi]; exact f5 i hi h5⟩
    · rw [hrbp, e8, hdl_read64 H HC hf hm (by omega) (by omega), ← e8]; exact f2
    · rw [hrbp, e0, hdl_read64 H HC hf hm (by omega) (by omega), ← e0]; exact f3


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
/-- `resume` (`handler resume [x] trap`): R unwinds from `k` with the exception object in slot
`x` (`R.unwindAt`). Proof idea: `handler_call_steps` reaches the handler (`H.envOutside.handler`,
an environment step); each return is `H.resume`'s: at the landing pad `PadsLinked` gives
(`cleanupAt k = some (some pad, _)`, `posOf_lt_32`), `rax` the slot's 8 bytes (related through
`MemRel`/`Rel` to R's `asPtr`), memory kept off runtime-owned bytes and the stack below `rsp`
(`EnvApart.window`, `CodeApart`, `LinkPrivate` keep `FrameInv`; `pad_not_leadArg`), the cache
empty at the pad (`CacheCleared.pads`); no pad: no return. -/
theorem handler_resume' (hD : Decodes S code relocs rodata callSites dropped scopes mode)
    (H : Hyps S) {k p : Nat} {a : Bool} {q : Proto} {cur c' : Cursor}
    (hP : ProtoFacts S k p q c' { pe := S.fr.mode.pe }) (hn : NoArg S.fr S.body p a cur)
    (hr : InsnRead S.fr S.ro cur q c') (hres : q.op = .resume) :
    BodySim S k p (S.used k) := by
  intro s x hs hf hrip _ hsafe
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
  -- the x86 side: the setup and `call resume`
  have hLp := bs_linkOk_at hf.code p
  obtain ⟨-, hhat, hbh⟩ := hLp.dec hd hP.bound
  obtain ⟨hca, hend, -⟩ := hLp.dec (hd.append (Dec.single hcall)) hP.bound
  obtain ⟨-, hlen, -, -⟩ := decodeItem_itemAt (c := atPos S.body hat) hf.code.fields
    hf.code.sorted hf.code.loaded hf.code.small hf.code.fp hbh hcall
  have hlen5 : len = 5 := by rw [← hlen]; rfl
  have hlo : S.lo.toNat + 8 ≤ x.rsp.toNat := by have := hf.room; omega
  have hreg : args.length ≤ (handlerRegs S.fr.mode.pe).length := H.regArgs s.pc _ _ _ hi
  obtain ⟨x2, hx2, hat2, hargs2, hrsp2, hsaved2, hmem2, hret2⟩ :=
    handler_call_ret (lo := S.lo) S.ctx H.linked hnop hsetup hreg hlo
  have hsteps := handler_call_steps H.fp hsetup hreg hca hrip hx2
  have hra : x2.mem.read64 x2.rsp = addrAt S.ctx (hat + 5) := by
    rw [hret2, hrip, addrAt_add', ← hlen5, hend]; rfl
  have hsite : (hat, 5) ∈ S.r.protos[k].sites := by rw [hpk]; simp
  have hpl := H.padsLinked k hlt (hat, 5) hsite (hat + 5) (by simp) (by simp)
  have hout := H.envOutside.handler .resume x2 hat2
  refine Reach.steps hsteps (.env hout fun x' hret => ?_)
  obtain ⟨hpad, -, hrsp', hsaved', hmem'⟩ := H.resume args off x2 x' hu hat2 hargs2 hret
  rw [hra, hpl] at hpad
  unfold unwindAt at hstep
  rw [hpc1] at hstep
  cases hcl : S.c.cleanupAt k with
  | none =>
    rw [hcl] at hstep
    exact (hE _ (hstep.trans rfl) (fun m h => by cases h)).elim
  | some pr =>
  obtain ⟨po, cat⟩ := pr
  cases po with
  | none => rw [hcl] at hpad; cases hpad
  | some pad =>
  rw [hcl] at hpad hstep
  have hpad' : x'.rip = addrAt S.ctx (posOf S.r pad) := by
    have h1 := (Option.some.inj hpad).symm
    rw [h1, hdl_base_setWidth]
    obtain ⟨hpl', -⟩ := pad_lpad hD hcl
    have := posOf_lt_32 hD hf.code hpl'
    simp only [pos32, BitVec.toNat_ofNat, Nat.mod_eq_of_lt this]
  have hnl := pad_not_leadArg hD hcl
  have hr1 := rrel_foldlM _ hf.rrel hsc
  have hm1 := (memRel_foldlM _ (H.frameBounds.scope_size _) hf.rrel hf.mem hsc).2
  have hsep1 := (sep_foldlM _ (H.frameBounds.scopesIn s.pc) (H.frameBounds.window hf.win)
    hf.rrel hf.sep hsc).2
  let s2 : R.RState := { s1 with pc := pad, st := { s1.st with exception := exc } }
  have hfi : FrameInv S s2 x :=
    ⟨⟨⟨fun o h1 h2 b hb => hr1.rel.frame o h1 h2 b hb, hr1.rel.layout, hr1.rel.zeroSized⟩,
      hr1.rbp, ⟨hr1.wf.idLt, hr1.wf.idInj⟩⟩, hm1, ⟨hsep1.own, hsep1.init, hsep1.dis, hsep1.space⟩, hk1.fp ▸ hf.win, hk1.fp ▸ hf.fpF, hf.rsp, hf.room,
      hf.code, hf.ro, fun h => absurd h hnl, hf.frame⟩
  have h8 : 8 ≤ x.rsp.toNat := by omega
  have hag : Counter.Agree S.Owned S.lo x x' := by
    refine ⟨by rw [hrsp', hrsp2]; exact BitVec.sub_add_cancel _ _,
      fun i hi => by rw [hsaved' i (Or.inl hi), hsaved2 i (Or.inl hi)], fun a ho hst => ?_⟩
    rw [hmem' a ho ?_, hmem2 a hst]
    intro ⟨h1, h2⟩
    apply hst
    refine ⟨h1, ?_⟩
    rw [hrsp2, BitVec.toNat_sub] at h2
    have := x.rsp.isLt
    simp at h2
    omega
  have hfin := hdl_frameInv H HA hfi hag (fun i hi => by rw [hsaved' i hi, hsaved2 i hi]) hnl
  have hstep' : R.step S.c s {} = .ok (.step s2) := hstep.trans rfl
  refine .done (.inl ⟨s2, .step hstep', hfin, .inr ⟨hpad', ?_⟩⟩)
  show CacheInv (S.used pad) x'
  rw [H.cacheCleared.pads k pad cat hcl]
  exact CacheInv.emptyPe _ _

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
  have hr0 : i ≠ Reg.rax.idx := h0
  have hr1 : i ≠ Reg.rcx.idx := h1
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
  simp [State.setReg, State.jump, State.setFlags, hr0, hr1, h0, h1]

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
  obtain ⟨⟨hrel, hb, hwf⟩, hmem, hsep, hwin, hfpF, hsp, hroom, hcode, hro, -, hfr⟩ := hf
  obtain ⟨f1, f2, f3, f5⟩ := hfr
  exact ⟨⟨Inline.rel_congr hrel hrbp hm, hrbp.trans hb, hwf⟩, Shapes.memRel_congr hm hmem,
    hsep.congr hrbp, hwin, hfpF, by rw [hrsp, hrbp]; exact hsp, by rw [hrsp]; exact hroom,
    by rw [hm]; exact hcode, by rw [hm]; exact hro, fun h => absurd h ha,
    ⟨by rw [hrbp]; exact f1, by rw [hrbp, hm]; exact f2, by rw [hrbp, hm]; exact f3,
      fun i hi h5 => by rw [hsv i hi]; exact f5 i hi h5⟩⟩

set_option maxRecDepth 100000 in
/-- A handler leaves the code, the rodata and the frame's link slots alone, and none is on the
stack below `rsp` (as `island_kept'`: the frame writes lie in the window, `FrameBounds.handler`,
and off the link slots, `FrameBounds.handlerOff`). -/
theorem hdl_kept (H : Hyps S) {s s1 : R.RState} {x x2 : X86.State} (hf : FrameInv S s x)
    (hci : CacheInv (S.used s.pc) x)
    (hsc : (S.c.scopesAt s.pc).foldlM R.applyScope s = .ok s1)
    {h : Full.Opcode} {args : List R.Arg} {t : R.Then Nat} {vals : Operands}
    (hi : S.c.d.insns[s.pc]? = some (.handler h args t))
    (hu : R.unpack S.c.ρ h S.c.mode args = some vals)
    (hrbp2 : x2.reg .rbp = x.reg .rbp) (hrsp2 : x2.rsp.toNat ≤ x.rsp.toNat)
    (b : BitVec 64) (hb : IslandKept S x b) :
    ¬ Handler.MayWrite S.Owned S.lo h vals s1.st x2 b ∧ ¬ InStack S.lo x.rsp b := by
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
  -- A byte off the window: in no frame write range.
  have hwr_win : ∀ b, (∀ o : Int, -(S.F : Int) ≤ o → o < S.K → b ≠ S.winAddr o) →
      ¬ ∃ r ∈ wranges h vals, (b - fpAddr x2 r.1).toNat < r.2 := by
    rintro b hnw ⟨r, hr, hlt⟩
    have hr' := hwr r hr
    rw [Island.fpAddr_eq_lendAddr hrbpX2] at hlt
    refine hnw (r.1 + (b - Island.lendAddr s.fp r.1).toNat) (by omega) (by omega) ?_
    rw [hW, island_ofInt_add, ← BitVec.add_assoc]
    exact island_sub_toNat rfl
  have hbi : BInv S s (x.jump (addrAt S.ctx (posOf S.r s.pc))) :=
    ⟨hf.congr rfl rfl rfl, .inr ⟨rfl, hci⟩⟩
  -- A code or rodata byte.
  have hcode : ∀ b, ((∃ p, p < S.body.code.size ∧ b = addrAt S.ctx p) ∨
      (∃ j, j < S.ro.size ∧ b = S.ctx.addrOf (.ro j))) →
      ¬ Handler.MayWrite S.Owned S.lo h vals s1.st x2 b ∧ ¬ InStack S.lo x.rsp b := by
    intro b hb'
    obtain ⟨hown, hstk, hnw, hal⟩ := H.codeApart b hb'
    have hst : ¬ InStack S.lo x.rsp b := hdl_inStack_lift H hf hstk
    refine ⟨?_, hst⟩
    rintro (hwb | hal1 | ho | hst2)
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
    rintro (⟨r, hr, hlt⟩ | ⟨id, al, hg, hlv, hlt⟩ | ho | hst2)
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

set_option maxHeartbeats 1000000 in
/-- The setup, `call h` and the handler's return (`H.handler`, `SepAcross.handler`): each return
continues at the item after the call with `opSem`'s result for a choice, its control in the
return registers, and `FrameInv` of R's state after for any successor past the leading `arg`s
(the frame writes in the window, `FrameBounds.handler`; the code, rodata and link slots kept,
`hdl_kept`). -/
theorem hdl_call_reach (hD : Decodes S code relocs rodata callSites dropped scopes mode)
    (H : Hyps S)
    {Q : X86.State → Prop} {s s1 : R.RState} {x : X86.State} {p n : Nat}
    {h : Full.Opcode} {args : List R.Arg} {t : R.Then Nat} {vals : Operands} {items : List Item}
    (hf : FrameInv S s x) (hci : CacheInv (S.used s.pc) x) (hrip : x.rip = addrAt S.ctx p)
    (hca : CodeAt S.ctx x.mem (items ++ [Item.call (.handler n)]) p)
    (hn : Full.Opcode.ofNat? n = some h) (hhh : h.hasHandler = true)
    (hsetup : Handler.setupItems S.c.mode args = some items)
    (hi : S.c.d.insns[s.pc]? = some (.handler h args t))
    (hsc : (S.c.scopesAt s.pc).foldlM R.applyScope s = .ok s1)
    (hu : R.unpack S.c.ρ h S.c.mode args = some vals) (hno : Handler.NoUB h vals s1.st)
    (kont : ∀ x' ch ctl st', opSem h vals s1.st ch = .ok (ctl, st') → Handler.CtlIn ctl x' →
      x'.rip = addrAt S.ctx (p + codeSize (items ++ [Item.call (.handler n)])) →
      (∀ pc, ¬ LeadArg S pc → FrameInv S { s1 with pc, st := st' } x') → Reach S.ctx S.E Q x') :
    Reach S.ctx S.E Q x := by
  have hk := scopes_keeps _ hsc
  have hfb := H.frameBounds
  have hwinT : (s.fp : Int) + S.K ≤ 2 ^ 64 := hf.win
  have hfpF : S.F ≤ s.fp := hf.fpF
  obtain ⟨hrbN, hrspN, -, -, -, -, -⟩ := hdl_nums H hf
  have hsep1 : FrameSep (-(S.F : Int)) S.K s1.st x :=
    (sep_foldlM _ (hfb.scopesIn s.pc) (hfb.window hwinT) hf.rrel hf.sep hsc).2
  obtain ⟨hr1, hm1⟩ := memRel_foldlM _ (hfb.scope_size _) hf.rrel hf.mem hsc
  have hap : Handler.StackApart S.lo s1.st x :=
    Handler.FrameSep.stackApart hsep1
      (Handler.stack_off_window (by rw [hrbN, hrspN]; omega) (by rw [hrbN]; omega))
      (island_allocs' H hf hsc)
  have hlo : S.lo.toNat + 8 ≤ x.rsp.toNat := by have := hf.room; omega
  have hreg : args.length ≤ (handlerRegs S.c.mode.pe).length := H.regArgs s.pc _ _ _ hi
  obtain ⟨x2, hx2, hat2, hargs2, hrsp2, hsv2, hmem2, hret2⟩ :=
    handler_call_ret (lo := S.lo) S.ctx H.linked hn hsetup hreg hlo
  obtain ⟨x2', hx2', -, -, hH2, hrbp2, -, -⟩ :=
    handler_call (lo := S.lo) S.ctx H.linked hn hsetup hreg ⟨hr1.rel, hm1⟩ hap hlo
  have e2 : x2' = x2 := by
    rw [hx2] at hx2'
    exact (Switch.except_ok_inj hx2').symm
  rw [e2] at hH2 hrbp2
  have hsteps := handler_call_steps H.fp hsetup hreg hca hrip hx2
  have hra : x2.mem.read64 x2.rsp =
      addrAt S.ctx (p + codeSize (items ++ [Item.call (.handler n)])) := by
    rw [hret2, hrip, addrAt_add']; rfl
  have hrsp2le : x2.rsp.toNat ≤ x.rsp.toNat := by
    have h8 : (x.rsp - 8).toNat = x.rsp.toNat - 8 := by
      rw [BitVec.toNat_sub]; have := x.rsp.isLt; simp; omega
    rw [hrsp2, h8]; omega
  refine Reach.steps hsteps (.env (H.envOutside.handler h x2 hat2) fun x' hret => ?_)
  -- The return.
  obtain ⟨ch, ctl, st', hop, hH', hctl, hal⟩ :=
    H.sepAcross.handler h args vals s1.st x2 x' x hhh hu hat2 hargs2 hH2 hno hret hsep1
  obtain ⟨-, -, -, -, -, -, hrsp', hrip', hsv', hmw⟩ :=
    H.handler.sound h args vals s1.st x2 x' hhh hu hat2 hargs2 hH2 hno hret
  refine kont x' ch ctl st' hop hctl (by rw [hrip', hra]) fun pc hnl => ?_
  have hrbp' : x'.reg .rbp = x.reg .rbp := by
    show x'.regs 5 = x.regs 5
    rw [hsv' 5 (by simp [CalleeSaved])]
    exact hrbp2
  have hrspX : x'.rsp = x.rsp := by
    rw [hrsp', hrsp2]; exact BitVec.sub_add_cancel _ _
  have hsvX : ∀ i, Saved S.c.mode.pe i → x'.regs i = x.regs i := by
    intro i hi
    rcases hi with hc | ⟨hpe, h67⟩
    · rw [hsv' i hc]; exact hsv2 i (Or.inl hc)
    · obtain ⟨h6, h7⟩ := H.peSaved hpe x2 x' hret
      rcases h67 with rfl | rfl
      · rw [h6]; exact hsv2 6 (Or.inr ⟨hpe, Or.inl rfl⟩)
      · rw [h7]; exact hsv2 7 (Or.inr ⟨hpe, Or.inr rfl⟩)
  have hkeep : ∀ b, IslandKept S x b → x'.mem b = x.mem b := by
    intro b hb
    obtain ⟨h1, h2⟩ := hdl_kept H hf hci hsc hi hu hrbp2 hrsp2le b hb
    rw [hmw b h1, hmem2 b h2]
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
  have hsep' : FrameSep (-(S.F : Int)) S.K st' x' :=
    FrameSep.extend hsep1 hrbp' hesc hal.1 hinit hal.2.1 hal.2.2
  have hwf' : EscWF st' := (H.opFacts h).escWF vals s1.st ch ctl st' hop hr1.wf
  refine ⟨⟨hH'.rel, ?_, hwf'⟩, hH'.mem, hsep', ?_, ?_, ?_, ?_, island_link_kept hf.code hkeep,
    island_ro_kept hf.ro hkeep, fun ha => absurd ha hnl,
    island_frame_kept hf.frame hkeep hrbp' (fun i hi _ => hsvX i hi)⟩
  · show x'.reg .rbp = BitVec.ofNat 64 s1.fp
    rw [hrbp', hf.rrel.rbp, hk.fp]
  · show (s1.fp : Int) + S.K ≤ 2 ^ 64
    rw [hk.fp]; exact hwinT
  · show S.F ≤ s1.fp
    rw [hk.fp]; exact hfpF
  · rw [hrspX, hrbp']; exact hf.rsp
  · rw [hrspX]; exact hf.room

/-- Falling through to instruction `k + 1` at `pC` (after PE's `nop`, as in `bodySim_island`). -/
theorem hdl_fallthrough {k pC : Nat} {q : Proto} {s s' : R.RState} {y : X86.State}
    (hnop : NopRead S.fr S.callSites S.body q pC (S.start (k + 1)))
    (hlk : LinkOk S.ctx y.mem S.body S.rs) (hb : Boundary S.rs pC)
    (hyrip : y.rip = addrAt S.ctx pC) (hnext : RNext S.c s s') (hpc : s'.pc = k + 1)
    (hfi : FrameInv S s' y) (hcache : S.cache (k + 1) = { pe := S.fr.mode.pe }) :
    Reach S.ctx S.E (SNext S s) y := by
  have fin : ∀ z : X86.State, z.regs = y.regs → z.xmm = y.xmm → z.mem = y.mem →
      z.rip = addrAt S.ctx (S.start (k + 1)) → Reach S.ctx S.E (SNext S s) z := by
    intro z hzr hzx hzm hzrip
    refine .done (.inl ⟨s', hnext, hfi.congr hzr hzx hzm, .inl ⟨?_, ?_⟩⟩)
    · rw [hpc]; exact hzrip
    · rw [hpc, hcache]; exact CacheInv.emptyPe _ _
  generalize hE : S.start (k + 1) = pE at hnop fin
  cases hnop with
  | none _ => exact fin y rfl rfl rfl hyrip
  | nop _ hby hrl =>
    obtain ⟨hit, -, -⟩ := nop_itemAt hlk (p := pC) (n := 1) (by omega) (by omega)
      (island_nop_bytes hby) hrl hb
    refine reach_padding (ns := [1]) (by simp) ⟨hit, trivial⟩ hyrip fun z h1 h2 h3 h4 => ?_
    refine fin z h1 h2 h3 ?_
    rw [h4]; rfl

set_option maxHeartbeats 1000000 in
/-- The `br` shape's tail after the return: `test al, al; jz/jnz tgt` (`Handler.br_tail`), to the
target (not a leading `arg`, `ArgsOk.untargeted`; the cache cleared there,
`CacheCleared.targets`) or falling through. -/
theorem hdl_br (H : Hyps S) {k pT j pc : Nat} {q : Proto} {c3 : Cursor} {s s1 : R.RState}
    {x' : X86.State} {st' : OpSem.State} {ch : OpSem.Choice} {b : Bool} {cond : Cond}
    {tgt : BitVec 32} {long : Bool}
    (hs : s.pc = k) (hlt : k < S.r.protos.size)
    (htg : tgt.toNat ∈ S.r.protos[k].targets) (hj : posOf S.r j = tgt.toNat)
    (hcond : cond = .z ∨ cond = .nz)
    (hdec : Dec (atPos S.body pT) pT [.testAl, .branch cond tgt long] c3.pos)
    (hbT0 : Boundary S.rs pT) (hrip : x'.rip = addrAt S.ctx pT)
    (hal : Handler.CtlIn (.branch b) x')
    (hFI : ∀ pc, ¬ LeadArg S pc → FrameInv S { s1 with pc, st := st' } x')
    (hpc : (if (b != (cond == Cond.z)) = true then j else s.pc + 1) = pc)
    (hstep : R.step S.c s ch = .ok (.step { s1 with pc, st := st' }))
    (hnl : ¬ LeadArg S (k + 1))
    (hnop : NopRead S.fr S.callSites S.body q c3.pos (S.start (k + 1)))
    (hcache : S.cache (k + 1) = { pe := S.fr.mode.pe }) :
    Reach S.ctx S.E (SNext S s) x' := by
  have hce : cond = (if (cond == Cond.z) = true then Cond.z else Cond.nz) := by
    rcases hcond with rfl | rfl <;> rfl
  have hnl' : ¬ LeadArg S (s.pc + 1) := by rw [hs]; exact hnl
  have hfk := hFI (s.pc + 1) hnl'
  have hlkT : LinkOk S.ctx x'.mem (atPos S.body pT) S.rs := bs_linkOk_at hfk.code pT
  obtain ⟨hcaT, hqT, hbT⟩ := hlkT.dec hdec hbT0
  obtain ⟨n1, n2, h1, h2, -⟩ := hdl_dec2 hdec
  obtain ⟨-, hq1, -⟩ := hlkT.dec (Dec.single h1) hbT0
  have hn1 : n1 = Item.testAl.size := by
    simp only [codeSize, List.map_cons, List.map_nil, List.sum_cons, List.sum_nil] at hq1
    omega
  have hcanB : (Item.branch cond tgt long).Canonical (pT + Item.testAl.size) := by
    rw [← hn1]; exact branch_canonical (c := S.body) hfk.code.fp h2
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
    rw [if_pos hbn] at hpc
    rw [if_pos hbn] at hrip2
    rw [← hpc] at hstep
    have hnlj : ¬ LeadArg S j := H.argsOk.untargeted k hlt _ htg j hj
    have hfj := (hFI j hnlj).congr hregs hxmm hmem
    refine Reach.steps hst (.done (.inl ⟨_, .step hstep, hfj, .inr ⟨?_, ?_⟩⟩))
    · show x''.rip = addrAt S.ctx (posOf S.r j)
      rw [hrip2, hdl_base_setWidth, hj]
    · show CacheInv (S.used j) x''
      have hc := H.cacheCleared.targets k hlt _ htg
      simp only [Setup.used, hj, hc, ↓reduceIte]
      exact CacheInv.emptyPe _ _
  · -- Not taken: falling through.
    have hnb : ¬ ((b != (cond == Cond.z)) = true) := by simp [hbn]
    rw [if_neg hnb] at hpc
    rw [if_neg hnb] at hrip2
    rw [← hpc] at hstep
    have hripC : x''.rip = addrAt S.ctx c3.pos := by
      (rw [hrip2, hrip, addrAt_add', hqT]) <;>
        simp only [codeSize, List.map_cons, List.map_nil, List.sum_cons, List.sum_nil,
          Nat.add_zero]
    exact Reach.steps hst (hdl_fallthrough hnop (by rw [hmem]; exact hfk.code) hbT hripC
      (.step hstep) (by show s.pc + 1 = k + 1; rw [hs]) (hfk.congr hregs hxmm hmem) hcache)

set_option maxHeartbeats 1000000 in
/-- The `switch` shape's tail after the return: the jump through the table
(`Switch.switch_tail`) to entry `i`'s target (not a leading `arg`, `ArgsOk.untargeted`; the
cache cleared there, `CacheCleared.targets`). -/
theorem hdl_switch (H : Hyps S) {k pT pc i pE : Nat} {s s1 : R.RState}
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
    (hFI : ∀ pc, ¬ LeadArg S pc → FrameInv S { s1 with pc, st := st' } x')
    (hstep : R.step S.c s ch = .ok (.step { s1 with pc, st := st' })) :
    Reach S.ctx S.E (SNext S s) x' := by
  have hnl : ¬ LeadArg S pc := H.argsOk.untargeted k hlt _ htg pc hpe
  have hfi := hFI pc hnl
  have hlkT : LinkOk S.ctx x'.mem (atPos S.body pT) S.rs := bs_linkOk_at hfi.code pT
  obtain ⟨hcaS, -, -⟩ := hlkT.dec hdT hbT0
  have htab : CodeAt S.ctx x'.mem (es.map (Item.tableEntry tb)) tb.toNat :=
    entries_codeAt hfi.code hes hbtb
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
  have hfi'' := hdl_frameInv_regs hfi hm hrbp hrsp hsv hnl
  refine Reach.steps hst (.done (.inl ⟨_, .step hstep, hfi'', .inr ⟨?_, ?_⟩⟩))
  · show x''.rip = addrAt S.ctx (posOf S.r pc)
    rw [hrip'', hpe]
  · show CacheInv (S.used pc) x''
    have hc := H.cacheCleared.targets k hlt _ htg
    simp only [Setup.used, hpe, hc, ↓reduceIte]
    exact CacheInv.emptyPe _ _

set_option maxHeartbeats 1000000 in
set_option maxRecDepth 100000 in
/-- A handler call other than `resume` (see `bodySim_handler'`). -/
theorem handler_general' (hD : Decodes S code relocs rodata callSites dropped scopes mode)
    (H : Hyps S) {k p : Nat} {a : Bool} {q : Proto} {cur c' : Cursor}
    (hP : ProtoFacts S k p q c' { pe := S.fr.mode.pe }) (hn : NoArg S.fr S.body p a cur)
    (hr : InsnRead S.fr S.ro cur q c') (hh : q.handler ≠ none) (hres : q.op ≠ .resume)
    (hnd : ∀ c'', (denseSwitch S.fr).run cur ≠ .ok (some q, c''))
    (htable : HdlTables S) :
    BodySim S k p (S.used k) := by
  intro s x hs hf hrip hci hsafe
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
  have hLp := bs_linkOk_at hf.code p
  obtain ⟨hca, hend, hbe⟩ := hLp.dec (hd.append (Dec.single hcall)) hP.bound
  have hend' : hat + len = p + codeSize (items ++ [Item.call (.handler n)]) := hend
  have hbe' : Boundary S.rs (hat + len) := hbe
  refine hdl_call_reach hD H hf (by rw [hs]; exact hci) hrip hca hnop hhh hsetup hi hsc hu
    hno ?_
  intro x' ch ctl st' hop hctl hrip' hFI
  obtain ⟨pc, hpc, hstep⟩ := hsucc ch ctl st' hop
  have hripT : x'.rip = addrAt S.ctx (hat + len) := by rw [hrip', hend']
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
    exact hdl_fallthrough (pC := hat + len) hP.nop hfi.code hbe' hripT (.step hstep)
      (by show s.pc + 1 = k + 1; rw [hs]) hfi hP.cache
  | br hsh hcond hdecT hc3 =>
    obtain ⟨j, rfl, hj⟩ := thenMap_branch ht'
    obtain ⟨b, rfl, hpc'⟩ := hdl_succ_branch hpc
    have harg : op ≠ .arg := by
      rintro rfl
      rw [hdl_arg_shape] at hsh
      cases hsh
    exact hdl_br H (pT := hat + len) hs hlt
      (by rw [hpk]; simp [Proto.targets, R.Then.targets]) hj hcond hdecT hbe' hripT hctl hFI
      hpc' hstep (hdl_next_notLead hD hP harg) hP.nop hP.cache
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
    exact hdl_switch H (pT := hat + len) hlt hdT hbe' hripT hes htb hbtb hes31 hil' hpe
      (by
        rw [hpk]
        simp [Proto.targets, R.Then.targets] <;> exact ⟨es[i], List.getElem_mem hil', rfl⟩)
      hctl hFI hstep
  | trap hsh hdt hc3 =>
    have ht0 := thenMap_trap ht'
    subst ht0
    exact (hdl_succ_trap hpc).elim

/-- `bodySim_handler`: `resume` by `handler_resume'`, every other handler call by
`handler_general'` (`noArg_insn`, `InsnRead.handler` as in `link_handler`; `handler_rside` for
the R side under `RSafe`; `hdl_call_reach` for the setup, `call h` and the return under
`H.handler` and `SepAcross.handler`; then the shape's tail: `hdl_fallthrough` for `op`/`lpad`,
`hdl_br`, `hdl_switch`, and `trap` excluded by `RSafe`). Beyond `Hyps`: the decoder's read isn't
an inline dense switch (`hnd`, as `link_handler`'s: the dispatch has it from `insn_split`); the
switch tables' positions (`htable`, from the decoding and `tablesCheck`:
`DecodeLink.Tables.hdlTables_of_check`). -/
theorem bodySim_handler' (hD : Decodes S code relocs rodata callSites dropped scopes mode)
    (H : Hyps S) {k p : Nat} {a : Bool} {q : Proto} {cur c' : Cursor}
    (hP : ProtoFacts S k p q c' { pe := S.fr.mode.pe }) (hn : NoArg S.fr S.body p a cur)
    (hr : InsnRead S.fr S.ro cur q c') (hh : q.handler ≠ none)
    (hnd : ∀ c'', (denseSwitch S.fr).run cur ≠ .ok (some q, c''))
    (htable : HdlTables S) :
    BodySim S k p (S.used k) := by
  by_cases hres : q.op = .resume
  · exact handler_resume' hD H hP hn hr hres
  · exact handler_general' hD H hP hn hr hh hres hnd htable

end Insn

end Ryo.Proofs.DecodeSound
