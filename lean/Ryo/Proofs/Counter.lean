/-
Ryo.Proofs.Counter — a JIT counter check and its trip stub refine a no-op (aot.md §C2,
"Counters and stubs"; the trip contract is jit.md §E.2).

With `Mode.counters` the decoder (`Ryo.Vm.DecodeReduced`, `read`/`instructions`) accepts at the
entry and at each loop head the check `inc qword [rip + ctr]; jns stub`
(`[.ctrInc lp, .branch .ns stub long]`, `check`) and, after the code, the stubs
`entryStub back long` / `headStub head back long` (`lea r11, [rip + record]; (mov eax, head;)
call [r11 + 8|16]; jmp back`), where `back` is the position right after the check. Proved here:

- `check_ok`, `check_effect`: the check never faults (`SF` is defined after `inc`). It changes
  only the 8 counter bytes at `ctrAddr ctx lp`, the flags and `rip`: registers and `xmm`s are
  unchanged, and `rip` is past the check (`after`) if the incremented counter is negative
  (`SF` set, `jns` not taken), else the stub's address.
- `check_fallthrough`, `check_taken`: the two cases of `check_effect`.
- `stub_returns`: running a stub (`Run`, with the trip in place of its `call`) from any state
  `s` with `lo + 8 ≤ rsp` reaches `back`'s address with `rsp`, the callee-saved registers
  (`CalleeSaved`: `rbx rbp r12`–`r15`) and memory outside `Owned` and outside the stack below
  `s.rsp` (`[lo, s.rsp)`, `InStack`) as in `s`.
- `counter_noop`: from `x` at the check, either way (fall-through, or taken + stub + trip
  return) the program reaches `after` in a state that `Agree`s with `x`: `rsp`, the
  callee-saved registers, and memory outside `Owned ∪ [lo, x.rsp)`. Caller-saved registers
  (`rax` and `r11` are written by the stub, the trip may write the rest), the flags and the
  `xmm`s may differ. The frame relation (`Ryo.Proofs.Inline.Rel`) reads only `rbp` and frame
  memory, which is at or above `rsp` (no live data below `rsp`: at the entry the frame isn't
  set up yet, at a loop head the frame lies above `rsp`), so it is kept.

Assumed (the trip contract, `TripContract Owned lo Returns`): `Returns s s'` relates the
state `s` just after `call [r11 + d]` (return address pushed, `rip` at the callee) to the state
`s'` the trip returns in. Every return has `rip` the pushed return address, `rsp = s.rsp + 8`,
the callee-saved registers of `s`, and memory of `s` outside `Owned` (runtime-owned: the
records with their counters, the queue, code memory) and outside the stack below the caller's
`rsp` (`[lo, s.rsp + 8)`), given that stack has room for the return address
(`lo + 8 ≤ s.rsp + 8`). jit.md §E.2's contract (every register but `rax`, `r11` and the flags
kept) implies this one. Its other outcome (`Done`: transfer to JIT code, which never returns
here) is not covered: it is a property of the transfer target (`FnSim`), not of this code.
The counter bytes must be in `Owned` (`counter_noop`'s `hOwn`).

Modeling notes:
- `Run` runs items in order (as `execItems`), with `call [r11 + d]` followed by a `Returns`
  step. That is the stub's control flow: `lea`/`mov` fall through, the trip returns to the
  return address, which is the `jmp`'s position (`TripContract.ret_rip`), and the `jmp`'s
  target doesn't depend on `rip`. A `Returns` relation with no return (the trip never comes
  back) makes the claims vacuous: they are partial correctness.
- The register cache (`Ryo.Vm.Asm` `Cache`) need not survive the stub's writes of `rax` and
  `r11`: the decoder clears it at every branch target (second pass of `instructions`) before
  reading the check, and loop heads are branch targets (`read`'s `head` takes them from the
  same operands and handler targets `Proto.targets` collects); at the entry it starts empty.
  So no cached value lives across a check.
-/
import Ryo.X86.Exec
import Ryo.X86.Extra
import Ryo.X86.State
import Std.Tactic.BVDecide
import Ryo.Proofs.Inline.Rel

namespace Ryo.Proofs.Counter

open Ryo.X86

/-! ### The check -/

/-- The counter check at a loop head (`lp`) or the entry: `inc qword [rip + ctr]; jns stub`. -/
def check (lp : Bool) (stub : BitVec 32) (long : Bool) : List Item :=
  [.ctrInc lp, .branch .ns stub long]

/-- The address of the counter the check increments. -/
def ctrAddr (ctx : Ctx) (lp : Bool) : BitVec 64 :=
  ctx.addrOf (if lp then .recordLoopCtr else .record)

/-- The check's length in bytes. -/
def checkLen (lp : Bool) (stub : BitVec 32) (long : Bool) : Nat :=
  (Item.ctrInc lp).size + (Item.branch .ns stub long).size

/-- The address right after the check at `rip`. -/
def after (rip : BitVec 64) (lp : Bool) (stub : BitVec 32) (long : Bool) : BitVec 64 :=
  rip + BitVec.ofNat 64 (checkLen lp stub long)

/-- The counter's value after the check's increment. -/
def incremented (ctx : Ctx) (lp : Bool) (x : State) : BitVec 64 :=
  x.mem.read64 (ctrAddr ctx lp) + 1

/-- The state after the check's `inc`. -/
def afterInc (ctx : Ctx) (lp : Bool) (s : State) : State :=
  { s with rip := s.rip + BitVec.ofNat 64 (Item.ctrInc lp).size,
           mem := s.mem.write (ctrAddr ctx lp) 8 (incremented ctx lp s).toNat,
           flags := { (addF (s.mem.read64 (ctrAddr ctx lp)) 1).2 with cf := s.flags.cf } }

theorem exec_ctrInc (ctx : Ctx) (lp : Bool) (s : State) :
    (Item.ctrInc lp).exec ctx s = .ok (afterInc ctx lp s) :=
  rfl

theorem exec_branch_ns (ctx : Ctx) (t : BitVec 32) (long : Bool) (s : State) (b : Bool)
    (h : s.flags.sf = some b) :
    (Item.branch .ns t long).exec ctx s = .ok
      (if b then { s with rip := s.rip + BitVec.ofNat 64 (Item.branch .ns t long).size }
       else { s with rip := ctx.base + t.setWidth 64 }) := by
  cases b <;>
    simp [Item.exec, Cond.eval, need, h, State.jump, bind, Except.bind, pure, Except.pure,
      Functor.map, Except.map]

theorem check_eq (ctx : Ctx) (lp : Bool) (stub : BitVec 32) (long : Bool) (x : State) :
    execItems ctx (check lp stub long) x = .ok
      (if (incremented ctx lp x).msb then
        { afterInc ctx lp x with
          rip := (afterInc ctx lp x).rip + BitVec.ofNat 64 (Item.branch .ns stub long).size }
       else { afterInc ctx lp x with rip := ctx.base + stub.setWidth 64 }) := by
  have : execItems ctx (check lp stub long) x =
      (Item.branch .ns stub long).exec ctx (afterInc ctx lp x) := by
    simp only [execItems, check, List.foldlM, exec_ctrInc, bind, Except.bind, pure, Except.pure]
    cases (Item.branch .ns stub long).exec ctx (afterInc ctx lp x) <;> rfl
  rw [this, exec_branch_ns (b := (incremented ctx lp x).msb)]
  simp [afterInc, addF, incremented]

/-- The check never faults. -/
theorem check_ok (ctx : Ctx) (lp : Bool) (stub : BitVec 32) (long : Bool) (x : State) :
    ∃ x', execItems ctx (check lp stub long) x = .ok x' := by
  exact ⟨_, check_eq ctx lp stub long x⟩

/-- What the check does: registers and `xmm`s unchanged, memory unchanged outside the 8 counter
bytes, `rip` past the check if the incremented counter is negative, else at the stub. -/
theorem check_effect (ctx : Ctx) (lp : Bool) (stub : BitVec 32) (long : Bool) (x x' : State)
    (h : execItems ctx (check lp stub long) x = .ok x') :
    x'.regs = x.regs ∧ x'.xmm = x.xmm ∧
    (∀ y, 8 ≤ (y - ctrAddr ctx lp).toNat → x'.mem y = x.mem y) ∧
    x'.rip = (if (incremented ctx lp x).msb then after x.rip lp stub long
              else ctx.base + stub.setWidth 64) := by
  rw [check_eq, Except.ok.injEq] at h
  subst h
  refine ⟨?_, ?_, ?_, ?_⟩
  · split <;> rfl
  · split <;> rfl
  · intro y hy
    split <;> exact Mem.write_other _ _ _ _ _ hy
  · split
    · simp [afterInc, after, checkLen, BitVec.add_assoc, BitVec.ofNat_add]
    · rfl

theorem check_fallthrough (ctx : Ctx) (lp : Bool) (stub : BitVec 32) (long : Bool)
    (x x' : State) (h : execItems ctx (check lp stub long) x = .ok x')
    (hs : (incremented ctx lp x).msb = true) :
    x'.rip = after x.rip lp stub long ∧ x'.regs = x.regs ∧ x'.xmm = x.xmm ∧
    (∀ y, 8 ≤ (y - ctrAddr ctx lp).toNat → x'.mem y = x.mem y) := by
  obtain ⟨h1, h2, h3, h4⟩ := check_effect ctx lp stub long x x' h
  simp only [hs, ite_true] at h4
  exact ⟨h4, h1, h2, h3⟩

theorem check_taken (ctx : Ctx) (lp : Bool) (stub : BitVec 32) (long : Bool)
    (x x' : State) (h : execItems ctx (check lp stub long) x = .ok x')
    (hs : (incremented ctx lp x).msb = false) :
    x'.rip = ctx.base + stub.setWidth 64 ∧ x'.regs = x.regs ∧ x'.xmm = x.xmm ∧
    (∀ y, 8 ≤ (y - ctrAddr ctx lp).toNat → x'.mem y = x.mem y) := by
  obtain ⟨h1, h2, h3, h4⟩ := check_effect ctx lp stub long x x' h
  simp only [hs] at h4
  exact ⟨h4, h1, h2, h3⟩

/-! ### The trip contract and the stubs -/

/-- The callee-saved registers (SysV and PE): `rbx rbp r12`–`r15` by number (`rsp` is
treated on its own). The model's `Reg` names only `rbp` of them; the state has all 16. -/
def CalleeSaved (i : Fin 16) : Prop := i = 3 ∨ i = 5 ∨ i = 12 ∨ i = 13 ∨ i = 14 ∨ i = 15

/-- `a` is on the stack below `sp`, down to the limit `lo`: `lo ≤ a < sp` (unsigned). -/
def InStack (lo sp a : BitVec 64) : Prop := lo.toNat ≤ a.toNat ∧ a.toNat < sp.toNat

/-- The trip contract (jit.md §E.2, its returning outcome): `Returns s s'` for `s` just after
`call [r11 + d]` (return address at `s.rsp`, `rip` at the trip) and `s'` the state it returns
in. -/
structure TripContract (Owned : BitVec 64 → Prop) (lo : BitVec 64)
    (Returns : State → State → Prop) : Prop where
  ret_rip : ∀ s s', Returns s s' → s'.rip = s.mem.read64 s.rsp
  ret_rsp : ∀ s s', Returns s s' → s'.rsp = s.rsp + 8
  ret_saved : ∀ s s', Returns s s' → ∀ i, CalleeSaved i → s'.regs i = s.regs i
  ret_mem : ∀ s s', Returns s s' → lo.toNat + 8 ≤ (s.rsp + 8).toNat →
    ∀ a, ¬ Owned a → ¬ InStack lo (s.rsp + 8) a → s'.mem a = s.mem a

/-- Running items in order (as `execItems`), each `call [r11 + d]` followed by the trip's
return (`Returns`). -/
inductive Run (ctx : Ctx) (Returns : State → State → Prop) : List Item → State → State → Prop
  | nil (s : State) : Run ctx Returns [] s s
  | step (i : Item) (is : List Item) (s s1 s2 : State) : (∀ d, i ≠ .callR11 d) →
      i.exec ctx s = .ok s1 → Run ctx Returns is s1 s2 → Run ctx Returns (i :: is) s s2
  | call (d : BitVec 8) (is : List Item) (s s1 s2 s3 : State) :
      (Item.callR11 d).exec ctx s = .ok s1 → Returns s1 s2 → Run ctx Returns is s2 s3 →
      Run ctx Returns (.callR11 d :: is) s s3

/-- What the program keeps across a check: `rsp`, the callee-saved registers, and memory
outside `Owned` and the stack below `x.rsp`. -/
def Agree (Owned : BitVec 64 → Prop) (lo : BitVec 64) (x y : State) : Prop :=
  y.rsp = x.rsp ∧ (∀ i, CalleeSaved i → y.regs i = x.regs i) ∧
  ∀ a, ¬ Owned a → ¬ InStack lo x.rsp a → y.mem a = x.mem a

private theorem regs_setReg_saved (s : State) (i : Fin 16) (hi : CalleeSaved i) (r : Reg)
    (hr : r = .rax ∨ r = .r11) (v : BitVec 64) : (s.setReg r v).regs i = s.regs i := by
  have : i ≠ r.idx := by
    rcases hr with rfl | rfl <;> rcases hi with rfl | rfl | rfl | rfl | rfl | rfl <;> decide
  simp [State.setReg, this]

/-- The push of the return address writes only `[sp - 8, sp)`, which is in the stack. -/
private theorem push_other (lo sp a : BitVec 64) (hlo : lo.toNat + 8 ≤ sp.toNat)
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

/-- `call [r11 + d]`: `rsp` down 8, the other registers kept, memory kept outside the 8 bytes
of the return address. -/
private theorem callR11_effect (ctx : Ctx) (d : BitVec 8) (s s1 : State)
    (h : (Item.callR11 d).exec ctx s = .ok s1) :
    s1.rsp = s.rsp - 8 ∧ (∀ i, i ≠ Reg.rsp.idx → s1.regs i = s.regs i) ∧
    (∀ a, 8 ≤ (a - (s.rsp - 8)).toNat → s1.mem a = s.mem a) := by
  simp only [Item.exec, State.jump, State.push, pure, Except.pure, Except.ok.injEq] at h
  subst h
  refine ⟨?_, ?_, ?_⟩
  · simp [State.rsp, State.reg, State.setMem, State.setReg]
  · intro i hi
    simp [State.setMem, State.setReg, hi]
  · intro a ha
    exact Mem.write_other _ _ _ _ _ ha

/-- The common tail of both stubs: `call [r11 + d]`, the trip, `jmp back`. -/
private theorem tail_returns {Owned : BitVec 64 → Prop} {lo : BitVec 64}
    {Returns : State → State → Prop} (hC : TripContract Owned lo Returns) (ctx : Ctx)
    (d : BitVec 8) (back : BitVec 32) (long : Bool) (s y : State)
    (hlo : lo.toNat + 8 ≤ s.rsp.toNat)
    (hrun : Run ctx Returns [.callR11 d, .branch .always back long] s y) :
    y.rip = ctx.base + back.setWidth 64 ∧ Agree Owned lo s y := by
  cases hrun with
  | step _ _ _ _ _ hne => exact absurd rfl (hne d)
  | call _ _ _ s1 s2 _ h1 hR hrest =>
    cases hrest with
    | step _ _ _ s3 _ _ h3 hnil =>
      cases hnil with
      | nil =>
        simp only [Item.exec, Cond.eval, State.jump, bind, Except.bind, pure,
          Except.pure, ite_true, Except.ok.injEq] at h3
        subst h3
        obtain ⟨hsp, hregs, hmem⟩ := callR11_effect ctx d s s1 h1
        have hsp8 : s1.rsp + 8 = s.rsp := by rw [hsp]; exact BitVec.sub_add_cancel _ _
        refine ⟨rfl, ?_, ?_, ?_⟩
        · show s2.rsp = s.rsp
          rw [hC.ret_rsp _ _ hR, hsp8]
        · intro i hi
          show s2.regs i = s.regs i
          rw [hC.ret_saved _ _ hR i hi]
          apply hregs
          rcases hi with rfl | rfl | rfl | rfl | rfl | rfl <;> decide
        · intro a ha hs
          show s2.mem a = s.mem a
          rw [hC.ret_mem _ _ hR (by rw [hsp8]; exact hlo) a ha (by rw [hsp8]; exact hs)]
          exact hmem a (push_other lo s.rsp a hlo hs)

/-- A stub, its trip returning, comes back to `back` with `rsp`, the callee-saved registers and
memory outside `Owned` and the stack below `s.rsp` kept. -/
theorem stub_returns {Owned : BitVec 64 → Prop} {lo : BitVec 64}
    {Returns : State → State → Prop} (hC : TripContract Owned lo Returns) (ctx : Ctx)
    (items : List Item) (head : BitVec 64) (back : BitVec 32) (long : Bool)
    (hstub : items = entryStub back long ∨ items = headStub head back long)
    (s y : State) (hlo : lo.toNat + 8 ≤ s.rsp.toNat) (hrun : Run ctx Returns items s y) :
    y.rip = ctx.base + back.setWidth 64 ∧ Agree Owned lo s y := by
  -- `lea r11` and `mov eax` change only `rax`, `r11`, the flags and `rip`.
  have hkeep : ∀ s' : State, s'.rsp = s.rsp → (∀ i, CalleeSaved i → s'.regs i = s.regs i) →
      s'.mem = s.mem → ∀ d, Run ctx Returns [.callR11 d, .branch .always back long] s' y →
      y.rip = ctx.base + back.setWidth 64 ∧ Agree Owned lo s y := by
    intro s' hsp hreg hmem d hr
    obtain ⟨hrip, h1, h2, h3⟩ := tail_returns hC ctx d back long s' y (hsp ▸ hlo) hr
    refine ⟨hrip, h1.trans hsp, fun i hi => (h2 i hi).trans (hreg i hi), fun a ha hs => ?_⟩
    rw [h3 a ha (hsp ▸ hs), hmem]
  have rsp_rax : ∀ (t : State) (v : BitVec 64), (t.setReg .rax v).rsp = t.rsp := fun t v =>
    State.reg_setReg_other _ _ _ _ (by decide)
  have rsp_r11 : ∀ (t : State) (v : BitVec 64), (t.setReg .r11 v).rsp = t.rsp := fun t v =>
    State.reg_setReg_other _ _ _ _ (by decide)
  rcases hstub with rfl | rfl
  · cases hrun with
    | step _ _ _ s1 _ _ h1 hr =>
      simp only [Item.exec, State.jump, pure, Except.pure, Except.ok.injEq] at h1
      subst h1
      refine hkeep _ ?_ ?_ ?_ 8 hr
      rotate_left 2; · rfl
      · simp [State.rsp, State.reg, State.setReg, Reg.idx, Reg.num]
      · intro i hi
        exact regs_setReg_saved _ i hi .r11 (.inr rfl) _
  · cases hrun with
    | step _ _ _ s1 _ _ h1 hr =>
      cases hr with
      | step _ _ _ s2 _ _ h2 hr =>
        simp only [Item.exec, State.jump, pure, Except.pure, Except.ok.injEq] at h1
        subst h1
        simp only [Item.exec, State.jump] at h2
        split at h2 <;>
        · simp only [pure, Except.pure, Except.ok.injEq] at h2
          subst h2
          refine hkeep _ ?_ ?_ ?_ 16 hr
          rotate_left 2; · rfl
          · simp [State.setFlags, State.rsp, State.reg, State.setReg, Reg.idx, Reg.num]
          · intro i hi
            try simp only [State.setFlags]
            rw [regs_setReg_saved _ i hi .rax (.inl rfl)]
            exact regs_setReg_saved _ i hi .r11 (.inr rfl) _

/-! ### The check with its stub -/

/-- A counter check and its stub refine a no-op: from `x` at the check, the program reaches
`after` (the decoder's `back`) in a state agreeing with `x` on `rsp`, the callee-saved
registers and memory outside `Owned` and the stack below `x.rsp`; either directly (the
counter still negative) or through the stub, if the trip returns. -/
theorem counter_noop {Owned : BitVec 64 → Prop} {lo : BitVec 64}
    {Returns : State → State → Prop} (hC : TripContract Owned lo Returns) (ctx : Ctx)
    (lp : Bool) (stub : BitVec 32) (long : Bool) (items : List Item) (head : BitVec 64)
    (back : BitVec 32) (blong : Bool)
    (hstub : items = entryStub back blong ∨ items = headStub head back blong)
    (x x' : State)
    (hback : ctx.base + back.setWidth 64 = after x.rip lp stub long)
    (hOwn : ∀ k < 8, Owned (ctrAddr ctx lp + BitVec.ofNat 64 k))
    (hlo : lo.toNat + 8 ≤ x.rsp.toNat)
    (hx : execItems ctx (check lp stub long) x = .ok x') :
    (x'.rip = after x.rip lp stub long ∧ Agree Owned lo x x') ∨
    (x'.rip = ctx.base + stub.setWidth 64 ∧
      ∀ y, Run ctx Returns items x' y → y.rip = after x.rip lp stub long ∧ Agree Owned lo x y) := by
  obtain ⟨hregs, -, hmem, hrip⟩ := check_effect ctx lp stub long x x' hx
  have hrsp : x'.rsp = x.rsp := by simp [State.rsp, State.reg, hregs]
  have hagree : Agree Owned lo x x' := by
    refine ⟨hrsp, fun i _ => by rw [hregs], fun a ha _ => hmem a ?_⟩
    apply Classical.byContradiction
    intro hlt
    apply ha
    have : a = ctrAddr ctx lp + BitVec.ofNat 64 (a - ctrAddr ctx lp).toNat := by
      rw [BitVec.ofNat_toNat, BitVec.setWidth_eq]; bv_omega
    rw [this]
    exact hOwn _ (by omega)
  split at hrip
  · exact .inl ⟨hrip, hagree⟩
  · refine .inr ⟨hrip, fun y hy => ?_⟩
    obtain ⟨hyrip, h1, h2, h3⟩ :=
      stub_returns hC ctx items head back blong hstub x' y (hrsp ▸ hlo) hy
    refine ⟨hyrip.trans hback, h1.trans hrsp, fun i hi => (h2 i hi).trans (hagree.2.1 i hi),
      fun a ha hs => ?_⟩
    rw [h3 a ha (hrsp ▸ hs), hagree.2.2 a ha hs]

/-! ### The frame relation across a check -/

/-- The frame relation survives anything that `Agree`s, as long as the frame bytes `opSem` can
read are neither runtime-owned nor on the stack below `rsp`. -/
theorem rel_of_agree {Owned : BitVec 64 → Prop} {lo : BitVec 64} {st : Ryo.Vm.OpSem.State}
    {x y : State} (hr : Ryo.Proofs.Inline.Rel st x) (ha : Agree Owned lo x y)
    (hf : ∀ o : Int, -2 ^ 63 ≤ o → o < 2 ^ 63 → (∃ b, st.byteAt o = .ok b) →
      ¬ Owned (Ryo.Proofs.Inline.fpAddr x o) ∧ ¬ InStack lo x.rsp (Ryo.Proofs.Inline.fpAddr x o)) :
    Ryo.Proofs.Inline.Rel st y := by
  have hrbp : y.reg .rbp = x.reg .rbp := ha.2.1 5 (Or.inr (Or.inl rfl))
  have hfp : ∀ o, Ryo.Proofs.Inline.fpAddr y o = Ryo.Proofs.Inline.fpAddr x o := fun o => by
    simp [Ryo.Proofs.Inline.fpAddr, hrbp]
  refine ⟨fun o h1 h2 b hb => ?_, fun e he a h => ?_, fun p hp => ?_⟩
  · obtain ⟨hn1, hn2⟩ := hf o h1 h2 ⟨b, hb⟩
    rw [hfp, ha.2.2 _ hn1 hn2]
    exact hr.frame o h1 h2 b hb
  · rw [hfp]; exact hr.layout e he a h
  · rw [hfp]; exact hr.zeroSized p hp

end Ryo.Proofs.Counter
