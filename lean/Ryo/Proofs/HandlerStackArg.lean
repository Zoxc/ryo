/-
Ryo.Proofs.HandlerStackArg — the pieces of a handler call with PE's stack argument (the fifth
position, `mov dword [rsp + 32], imm`, `stackItem`), for handler calls with PE's stack argument.

On PE the setup of five arguments is the four register items and then the store
(`setupItems_pe5`). The store writes `[rsp + 32, rsp + 36)` (`InStackArg`), above `rsp`, at the
frame's bottom (`fp - F + 32` in the body): unlike the push of the return address it is not on
the stack below `rsp`, so `StackApart` doesn't cover it.

- `ArgApart P`: `StackApart` over any address set `P` (no initialized private frame byte and no
  live allocation byte in `P`); `ArgApart.rel` keeps `Rel` and `MemRel` across a change confined
  to `P` (`StackApart.rel`'s proof); `StackApart.argApart`, `ArgApart.or` combine the two sets.
- `stackArg_apart`: `ArgApart (InStackArg rsp)` in the body (`rsp = fp - F`, `36 ≤ F`), from
  the frame separation over `[-F, K)` and the offsets `[-F + 32, -F + 36)` being private and
  `Uninit` after the scopes (the open prerequisite such a step needs; see the plan below).
- `handler_call5`: the setup of five arguments and `call h` on PE reach the handler with
  `ArgsIn` (the stack position included), `rsp` down 8, the registers outside `rcx, rdx, r8, r9`
  and `rsp` kept, memory kept outside the stack below `rsp` and the stack argument, and the
  return address at `rsp`; `hrel_after` gives `HRel` there.
- `inStackArg_eq_fpAddr`, `not_inStackArg_fpAddr`: the stack argument's bytes are the frame
  offsets `[-F + 32, -F + 36)` (for the kept bytes after the return: code, rodata and the link
  slots are elsewhere).
- `fetchRun_append_single`, `fetchRun_stImm`, `stImm_canonical`: fetching the setup when the
  store isn't `MemKept` (it keeps the code if the code is off the stack argument).
-/
import Ryo.Proofs.CallLemmas
import Ryo.Proofs.ScopeMem
import Ryo.X86.Fetch

set_option linter.constructorNameAsVariable false

namespace Ryo.Proofs.HandlerStackArg

open Ryo.Spec Ryo.Vm Ryo.Vm.OpSem Ryo.X86 Ryo.Vm.Asm Ryo.Proofs.Inline
open Ryo.Proofs.Handler
open Ryo.Proofs.Counter (CalleeSaved InStack)

private theorem okInj {ε α : Type} {a b : α} (h : (Except.ok a : Except ε α) = .ok b) : a = b := by
  cases h; rfl

/-! ### Keeping the relations across a change confined to an address set -/

/-- No byte the relations read is at an address in `P`: no initialized private frame byte and no
live allocation byte (`StackApart`, for `P` the stack below `rsp`). -/
def ArgApart (P : BitVec 64 → Prop) (st : OpSem.State) (x : X86.State) : Prop :=
  (∀ o : Int, -2 ^ 63 ≤ o → o < 2 ^ 63 → st.escapedAt o = none → st.frame o ≠ .uninit →
    ¬ P (fpAddr x o)) ∧
  (∀ id al, st.mem.get? id = some al → al.live = true → ∀ i < al.size,
    ¬ P (BitVec.ofNat 64 (al.addr + i)))

theorem StackApart.argApart {lo : BitVec 64} {st : OpSem.State} {x : X86.State}
    (h : StackApart lo st x) : ArgApart (InStack lo x.rsp) st x :=
  ⟨h.1, h.2⟩

theorem ArgApart.or {P Q : BitVec 64 → Prop} {st : OpSem.State} {x : X86.State}
    (hp : ArgApart P st x) (hq : ArgApart Q st x) : ArgApart (fun a => P a ∨ Q a) st x := by
  refine ⟨fun o h1 h2 he hu hc => ?_, fun id al hg hl i hi hc => ?_⟩
  · rcases hc with hc | hc
    · exact hp.1 o h1 h2 he hu hc
    · exact hq.1 o h1 h2 he hu hc
  · rcases hc with hc | hc
    · exact hp.2 id al hg hl i hi hc
    · exact hq.2 id al hg hl i hi hc

/-- `ArgApart P` keeps the frame and memory relations across a change of x86 memory confined
to `P`, with `rbp` kept (`StackApart.rel` for any `P`). -/
theorem ArgApart.rel {P : BitVec 64 → Prop} {st : OpSem.State} {x y : X86.State}
    (hap : ArgApart P st x) (hr : Rel st x) (hm : MemRel st x)
    (hb : y.reg .rbp = x.reg .rbp) (hmem : ∀ a, ¬ P a → y.mem a = x.mem a) :
    Rel st y ∧ MemRel st y := by
  have hfp : ∀ o, fpAddr y o = fpAddr x o := fun o => by simp [fpAddr, hb]
  refine ⟨⟨fun o h1 h2 b hb' => ?_, fun e he a ha => ?_, fun p hp => ?_⟩, ?_⟩
  · rw [hfp]
    cases he : st.escapedAt o with
    | none =>
      have hbv : b = st.frame o := by
        unfold OpSem.State.byteAt at hb'; rw [he] at hb'
        simp only [pure, Except.pure, Except.ok.injEq] at hb'; exact hb'.symm
      by_cases hu : st.frame o = .uninit
      · rw [hbv, hu]; trivial
      rw [hmem _ (hap.1 o h1 h2 he hu)]; exact hr.frame o h1 h2 b hb'
    | some e =>
      have hb2 := hb'
      unfold OpSem.State.byteAt at hb2; rw [he] at hb2
      simp only at hb2
      split at hb2
      · rename_i al hal
        split at hb2
        · cases hb2
        · rename_i hlv
          split at hb2
          · rename_i b' hj
            obtain ⟨hj, -⟩ := Array.getElem?_eq_some_iff.1 hj
            obtain ⟨hem, h3, -⟩ := escapedAt_some he
            have hA : fpAddr x o = BitVec.ofNat 64 (al.addr + (o - e.off).toNat) := by
              rw [BitVec.ofNat_add, hr.layout e hem al hal, ← fpAddr_add]
              congr 1; omega
            rw [hmem _ (by rw [hA]; exact hap.2 e.id al hal (by simpa using hlv) _ hj)]
            exact hr.frame o h1 h2 b hb'
          · cases hb2
      · cases hb2
  · rw [hfp]; exact hr.layout e he a ha
  · rw [hfp]; exact hr.zeroSized p hp
  · intro id al hg hl i hi
    rw [hmem _ (hap.2 id al hg hl i hi)]
    exact hm id al hg hl i hi

/-! ### The stack argument's bytes -/

/-- `a` is a byte of PE's handler stack argument, `[sp + 32, sp + 36)` (`M.stackArg`, a
`dword`). -/
def InStackArg (sp a : BitVec 64) : Prop := (a - (sp + 32)).toNat < 4

theorem fpAddr_toNat {x : X86.State} {fp : Nat} {o : Int} (hb : x.reg .rbp = BitVec.ofNat 64 fp)
    (h0 : 0 ≤ (fp : Int) + o) (h1 : (fp : Int) + o < 2 ^ 64) :
    (fpAddr x o).toNat = ((fp : Int) + o).toNat := by
  simp only [fpAddr, hb, BitVec.toNat_add, BitVec.toNat_ofNat, BitVec.toNat_ofInt]
  omega

theorem rsp32_toNat {x : X86.State} {fp F : Nat} (hsp : x.rsp.toNat = fp - F) (hF : 36 ≤ F)
    (hFfp : F ≤ fp) (hfp : fp < 2 ^ 64) : (x.rsp + 32).toNat = fp - F + 32 := by
  have h32 : (32 : BitVec 64).toNat = 32 := rfl
  rw [BitVec.toNat_add, hsp, h32]
  omega

/-- A frame byte at or above `fp - F` is in the stack argument only at the offsets
`[-F + 32, -F + 36)`. -/
theorem inStackArg_fpAddr {x : X86.State} {fp F : Nat} {o : Int}
    (hb : x.reg .rbp = BitVec.ofNat 64 fp) (hsp : x.rsp.toNat = fp - F) (hF : 36 ≤ F)
    (hFfp : F ≤ fp) (hfp : fp < 2 ^ 64) (ho1 : -(F : Int) ≤ o) (ho2 : (fp : Int) + o < 2 ^ 64)
    (h : InStackArg x.rsp (fpAddr x o)) : -(F : Int) + 32 ≤ o ∧ o < -(F : Int) + 36 := by
  have hr := rsp32_toNat hsp hF hFfp hfp
  have hx := fpAddr_toNat hb (o := o) (by omega) ho2
  unfold InStackArg at h
  rw [BitVec.toNat_sub, hx, hr] at h
  omega

/-- A frame byte at or above `fp - F + 36` (e.g. a link slot) is not in the stack argument. -/
theorem not_inStackArg_fpAddr {x : X86.State} {fp F : Nat} {o : Int}
    (hb : x.reg .rbp = BitVec.ofNat 64 fp) (hsp : x.rsp.toNat = fp - F) (hF : 36 ≤ F)
    (hFfp : F ≤ fp) (hfp : fp < 2 ^ 64) (ho1 : -(F : Int) + 36 ≤ o)
    (ho2 : (fp : Int) + o < 2 ^ 64) : ¬ InStackArg x.rsp (fpAddr x o) := by
  intro h
  have := inStackArg_fpAddr hb hsp hF hFfp hfp (by omega) ho2 h
  omega

/-- The stack argument's bytes are the frame offsets `[-F + 32, -F + 36)`. -/
theorem inStackArg_eq_fpAddr {x : X86.State} {fp F : Nat} {b : BitVec 64}
    (hb : x.reg .rbp = BitVec.ofNat 64 fp) (hsp : x.rsp.toNat = fp - F) (hF : 36 ≤ F)
    (hFfp : F ≤ fp) (hfp : fp < 2 ^ 64) (h : InStackArg x.rsp b) :
    ∃ j : Nat, j < 4 ∧ b = fpAddr x (-(F : Int) + 32 + j) := by
  have hr := rsp32_toNat hsp hF hFfp hfp
  unfold InStackArg at h
  generalize hj : (b - (x.rsp + 32)).toNat = j at h
  rw [BitVec.toNat_sub, hr] at hj
  refine ⟨j, h, ?_⟩
  have hfo := fpAddr_toNat hb (o := -(F : Int) + 32 + j) (by omega) (by omega)
  apply BitVec.eq_of_toNat_eq
  rw [hfo]
  have := b.isLt
  omega

/-- In the body (`rbp = fp`, `rsp = fp - F`, `36 ≤ F`), the stack argument holds no byte the
relations read: from the frame separation over `[-F, K)` and the offsets `[-F + 32, -F + 36)`
private (`escapedAt = none`) and `Uninit` (`hpriv`). A live allocation byte there would be an
escaped object's (`FrameOwn`), so not private. -/
theorem stackArg_apart {x : X86.State} {st : OpSem.State} {fp F : Nat} {K : Int}
    (hb : x.reg .rbp = BitVec.ofNat 64 fp) (hsp : x.rsp.toNat = fp - F) (hF : 36 ≤ F)
    (hFfp : F ≤ fp) (hfp : fp < 2 ^ 64) (hwin : (fp : Int) + K ≤ 2 ^ 64) (hK : 0 ≤ K)
    (hs : ScopeMem.FrameSep (-(F : Int)) K st x)
    (hpriv : ∀ o : Int, -(F : Int) + 32 ≤ o → o < -(F : Int) + 36 →
      st.escapedAt o = none ∧ st.frame o = .uninit) :
    ArgApart (InStackArg x.rsp) st x := by
  refine ⟨fun o _ _ he hu hin => ?_, fun id al hg hl i hi hin => ?_⟩
  · obtain ⟨ho1, ho2⟩ := hs.init o he hu
    have hr := inStackArg_fpAddr hb hsp hF hFfp hfp ho1 (by omega) hin
    exact hu (hpriv o hr.1 hr.2).2
  · have hsp' := hs.space id al hg hl
    obtain ⟨j, hj, he⟩ := inStackArg_eq_fpAddr hb hsp hF hFfp hfp hin
    have hi' : i < al.size := hi
    have hlt : al.addr + i < 2 ^ 64 := Nat.lt_of_lt_of_le (Nat.add_lt_add_left hi _) hsp'
    have hlt' : al.addr < 2 ^ 64 := by omega
    have ha : (BitVec.ofNat 64 (al.addr + i)).toNat = al.addr + i := by
      rw [BitVec.toNat_ofNat, Nat.mod_eq_of_lt hlt]
    have hA : (BitVec.ofNat 64 al.addr).toNat = al.addr := by
      rw [BitVec.toNat_ofNat, Nat.mod_eq_of_lt hlt']
    have hfo := fpAddr_toNat hb (o := -(F : Int) + 32 + j) (by omega) (by omega)
    have hsum : al.addr + i = ((fp : Int) + (-(F : Int) + 32 + j)).toNat := by
      rw [← ha, ← hfo, he]
    obtain ⟨e, hem, he1, he2, -⟩ := hs.own id al (-(F : Int) + 32 + j) hg hl (by omega)
      (by omega) (by
        rw [BitVec.toNat_sub, hfo, hA, ← hsum]
        have e : 2 ^ 64 - al.addr + (al.addr + i) = i + 2 ^ 64 := by omega
        rw [e, Nat.add_mod_right, Nat.mod_eq_of_lt (by omega)]
        exact hi)
    exact ScopeMem.escapedAt_none (hpriv (-(F : Int) + 32 + j) (by omega) (by omega)).1 e hem
      ⟨he1, he2⟩

/-! ### The setup on PE with a stack argument -/

theorem stackItem_some {a : R.Arg} {it : Item} (h : stackItem a = some it) :
    ∃ v, a = .imm v ∧ v.toNat < 2 ^ 32 ∧ it = .stImm .d M.stackArg (v.setWidth 32) := by
  cases a with
  | imm v =>
    simp only [stackItem] at h
    split at h
    · next hv => exact ⟨v, rfl, hv, (Option.some.inj h).symm⟩
    · cases h
  | fp => simp [stackItem] at h
  | exception => simp [stackItem] at h
  | const _ => simp [stackItem] at h
  | data _ => simp [stackItem] at h
  | sym _ => simp [stackItem] at h
  | ro _ => simp [stackItem] at h

/-- On PE the setup of five arguments is the setup of the first four (into `rcx, rdx, r8, r9`)
and the stack argument's store. -/
theorem setupItems_pe5 {mode : Ryo.Obj.Mode} (hpe : mode.pe = true) {a0 a1 a2 a3 a4 : R.Arg}
    {items : List Item} (hs : setupItems mode [a0, a1, a2, a3, a4] = some items) :
    ∃ rItems it, items = rItems ++ [it] ∧ setupItems mode [a0, a1, a2, a3] = some rItems ∧
      stackItem a4 = some it := by
  have p0 : posItem mode 0 a0 = argItem mode .rcx a0 := by
    simp [posItem, handlerReg, handlerRegs, hpe]
  have p1 : posItem mode 1 a1 = argItem mode .rdx a1 := by
    simp [posItem, handlerReg, handlerRegs, hpe]
  have p2 : posItem mode 2 a2 = argItem mode .r8 a2 := by
    simp [posItem, handlerReg, handlerRegs, hpe]
  have p3 : posItem mode 3 a3 = argItem mode .r9 a3 := by
    simp [posItem, handlerReg, handlerRegs, hpe]
  have p4 : posItem mode 4 a4 = stackItem a4 := by
    simp [posItem, handlerReg, handlerRegs, hpe]
  have hle : ([a0, a1, a2, a3] : List R.Arg).length ≤ (handlerRegs mode.pe).length := by
    simp [handlerRegs, hpe]
  have hregs : handlerRegs mode.pe = [.rcx, .rdx, .r8, .r9] := by
    rw [hpe]; rfl
  have h5 : ([a0, a1, a2, a3, a4] : List R.Arg).length ≤ handlerPositions mode.pe := by
    simp [handlerPositions, hpe]
  unfold setupItems at hs
  rw [ite_eq_left h5] at hs
  simp only [List.zipIdx_cons, List.zipIdx_nil, List.mapM_cons, List.mapM_nil, Nat.zero_add,
    Nat.reduceAdd, p0, p1, p2, p3, p4] at hs
  cases h0 : argItem mode .rcx a0 with
  | none => rw [h0] at hs; simp at hs
  | some i0 =>
  cases h1 : argItem mode .rdx a1 with
  | none => rw [h0, h1] at hs; simp at hs
  | some i1 =>
  cases h2 : argItem mode .r8 a2 with
  | none => rw [h0, h1, h2] at hs; simp at hs
  | some i2 =>
  cases h3 : argItem mode .r9 a3 with
  | none => rw [h0, h1, h2, h3] at hs; simp at hs
  | some i3 =>
  cases h4 : stackItem a4 with
  | none => rw [h0, h1, h2, h3, h4] at hs; simp at hs
  | some it =>
  rw [h0, h1, h2, h3, h4] at hs
  have hs' : some [i0, i1, i2, i3, it] = some items := hs
  obtain rfl := Option.some.inj hs'
  refine ⟨[i0, i1, i2, i3], it, rfl, ?_, rfl⟩
  rw [setupItems_regs hle, hregs]
  simp only [List.zip_cons_cons, List.zip_nil_right, List.mapM_cons,
    List.mapM_nil, h0, h1, h2, h3] <;> rfl

/-- A setup's arguments are in registers, or on PE they are five (the fifth on the stack):
at most `handlerRegs` everywhere but PE's five-argument calls. -/
theorem setupItems_length {mode : Ryo.Obj.Mode} {args : List R.Arg} {items : List Item}
    (hs : setupItems mode args = some items) :
    args.length ≤ (handlerRegs mode.pe).length ∨ (mode.pe = true ∧ args.length = 5) := by
  unfold setupItems at hs
  split at hs
  · rename_i h
    cases hpe : mode.pe <;> rw [hpe] at h
    · left
      show args.length ≤ 6
      exact h
    · have h5 : args.length ≤ 5 := h
      by_cases h4 : args.length ≤ 4
      · left
        show args.length ≤ 4
        exact h4
      · right
        exact ⟨rfl, by omega⟩
  · cases hs

theorem eq_five {α : Type} {l : List α} (h : l.length = 5) :
    ∃ a0 a1 a2 a3 a4, l = [a0, a1, a2, a3, a4] := by
  rcases l with _ | ⟨a0, _ | ⟨a1, _ | ⟨a2, _ | ⟨a3, _ | ⟨a4, _ | ⟨a5, l⟩⟩⟩⟩⟩⟩
  all_goals first | (simp at h; done) | skip
  exact ⟨a0, a1, a2, a3, a4, rfl⟩

/-- The stack argument's store: memory written at `[rsp + 32, rsp + 36)`, the registers and the
`xmm`s kept. -/
theorem stImm_exec (ctx : Ctx) (w : BitVec 32) (x : X86.State) :
    ∃ y, (Item.stImm .d M.stackArg w).exec ctx x = .ok y ∧ y.regs = x.regs ∧ y.xmm = x.xmm ∧
      y.rip = x.rip + BitVec.ofNat 64 (Item.stImm .d M.stackArg w).size ∧
      y.mem = x.mem.write (x.rsp + 32) 4 w.toNat := by
  refine ⟨_, rfl, rfl, rfl, rfl, ?_⟩
  show x.mem.write (x.reg .rsp + (32 : BitVec 32).signExtend 64) (W.d.bits / 8)
      (w.signExtend W.d.bits).toNat = x.mem.write (x.rsp + 32) 4 w.toNat
  have e1 : (32 : BitVec 32).signExtend 64 = (32 : BitVec 64) := by decide
  have e2 : (w.signExtend W.d.bits).toNat = w.toNat := by
    show (w.signExtend 32).toNat = w.toNat
    first | rw [BitVec.signExtend_eq] | simp
  rw [e1, e2]
  rfl

theorem stImm_canonical (w : BitVec 32) (p : Nat) : (Item.stImm .d M.stackArg w).Canonical p := by
  unfold Item.Canonical
  exact ⟨fun _ _ h => (nomatch h), Or.inl (by first | rfl | decide)⟩

/-- Reading back the `dword` just written. -/
theorem memW_write_self (m : Mem) (a : BitVec 64) (w : BitVec 32) :
    BitVec.ofNat 32 ((m.write a 4 w.toNat).readNat a 4) = w := by
  have := CallLemmas.readNat_write_self m a 4 w.toNat (by decide) 0 4 (by omega)
  simp only [BitVec.add_zero, Nat.mul_zero, Nat.shiftRight_zero] at this
  rw [this]
  apply BitVec.eq_of_toNat_eq
  simp [Nat.mod_eq_of_lt w.isLt]

/-- The stack argument's bytes are above the pushed return address. -/
theorem above_push32 (a : BitVec 64) (i : Nat) (hi : i < 4) :
    8 ≤ (a + 32 + BitVec.ofNat 64 i - (a - 8)).toNat := by
  have : a + 32 + BitVec.ofNat 64 i - (a - 8) = BitVec.ofNat 64 (i + 40) := by
    rw [BitVec.ofNat_add]; generalize BitVec.ofNat 64 i = c; bv_omega
  rw [this, BitVec.toNat_ofNat, Nat.mod_eq_of_lt (by omega)]; omega

/-! #### Registers through the register items (`DSWork/Handler.lean`'s `handler_setup_regs`) -/

theorem argItem_regs (ctx : Ctx) {mode : Ryo.Obj.Mode} {r : X86.Reg} {a : R.Arg}
    {it : Item} (h : argItem mode r a = some it) {x y : X86.State}
    (he : it.exec ctx x = .ok y) : ∀ i, i ≠ r.idx → y.regs i = x.regs i := by
  intro i hi
  cases a with
  | fp =>
    simp only [argItem, fpItem, Option.some.injEq] at h
    split at h <;> subst h <;> simp only [Item.exec] at he <;> cases okInj he <;>
      simp [State.setReg, State.jump, hi]
  | exception =>
    simp only [argItem, Option.some.injEq] at h; subst h
    simp only [Item.exec] at he; cases okInj he; simp [State.setReg, State.jump, hi]
  | imm v =>
    simp only [argItem, Option.some.injEq] at h; subst h
    simp only [Item.exec] at he
    split at he <;> cases okInj he <;>
      simp [State.setReg, State.setFlags, State.jump, hi]
  | const _ | data _ | sym _ | ro _ =>
    simp only [argItem, argRef, Option.map_some, Option.some.injEq] at h; subst h
    simp only [Item.exec] at he; cases okInj he; simp [State.setReg, State.jump, hi]

theorem setup_regs (ctx : Ctx) (mode : Ryo.Obj.Mode) :
    ∀ (args : List R.Arg) (regs : List X86.Reg) (items : List Item) (x y : X86.State),
    (args.zip regs).mapM (fun (a, r) => argItem mode r a) = some items →
    execItems ctx items x = .ok y → ∀ i : Fin 16, (∀ r ∈ regs, r.idx ≠ i) → y.regs i = x.regs i
  | [], regs, items, x, y, h, he, i, hi => by
    simp only [List.zip_nil_left, List.mapM_nil, pure, Option.some.injEq] at h; subst h
    cases okInj he; rfl
  | a :: args, [], items, x, y, h, he, i, hi => by
    simp only [List.zip_nil_right, List.mapM_nil, pure, Option.some.injEq] at h; subst h
    cases okInj he; rfl
  | a :: args, r :: regs, items, x, y, h, he, i, hi => by
    simp only [List.zip_cons_cons, List.mapM_cons, bind, Option.bind] at h
    cases hit : argItem mode r a with
    | none => simp [hit] at h
    | some it =>
      simp only [hit] at h
      cases hrest : (args.zip regs).mapM (fun (a, r) => argItem mode r a) with
      | none => simp [hrest] at h
      | some its =>
        simp only [hrest, pure, Option.some.injEq] at h
        subst h
        rw [X86.execItems_cons] at he
        cases hy : it.exec ctx x with
        | error e => rw [hy] at he; cases he
        | ok y1 =>
          rw [hy] at he
          rw [setup_regs ctx mode args regs its y1 y hrest he i
            (fun r' hr' => hi r' (List.mem_cons_of_mem _ hr')),
            argItem_regs ctx hit hy i (fun e => hi r (List.mem_cons_self ..) e.symm)]

/-! ### The setup and the call -/

set_option maxHeartbeats 1000000 in
/-- On PE, the setup of five arguments (four registers and the stack argument) and `call h`
reach the handler with the arguments in place (`ArgsIn`, the stack position included), `rsp`
down 8, `rbp` and every register outside `rcx, rdx, r8, r9` and `rsp` kept, memory kept outside
the stack below `rsp` and the stack argument, and the return address at `rsp`. -/
theorem handler_call5 {ρ : R.Addrs} {mode : Ryo.Obj.Mode} {lo : BitVec 64} (ctx : Ctx)
    (hl : Linked ctx ρ) (hpe : mode.pe = true) {h : Full.Opcode} {n : Nat}
    (hn : Full.Opcode.ofNat? n = some h) {a0 a1 a2 a3 a4 : R.Arg} {items : List Item}
    (hs : setupItems mode [a0, a1, a2, a3, a4] = some items)
    {x : X86.State} (hlo : lo.toNat + 8 ≤ x.rsp.toNat) :
    ∃ x2, execItems ctx (items ++ [Item.call (.handler n)]) x = .ok x2 ∧
      AtHandler ctx h x2 ∧ ArgsIn ρ mode.pe x2 x2 [a0, a1, a2, a3, a4] ∧
      x2.rsp = x.rsp - 8 ∧ x2.reg .rbp = x.reg .rbp ∧
      (∀ i : Fin 16, (∀ r ∈ handlerRegs mode.pe, r.idx ≠ i) → i ≠ 4 → x2.regs i = x.regs i) ∧
      (∀ a, ¬ InStack lo x.rsp a → ¬ InStackArg x.rsp a → x2.mem a = x.mem a) ∧
      x2.mem.read64 x2.rsp =
        x.rip + BitVec.ofNat 64 ((items ++ [Item.call (.handler n)]).map Item.size).sum := by
  obtain ⟨rItems, it, rfl, hs4, h4⟩ := setupItems_pe5 hpe hs
  obtain ⟨v, rfl, hv32, rfl⟩ := stackItem_some h4
  have hle : ([a0, a1, a2, a3] : List R.Arg).length ≤ (handlerRegs mode.pe).length := by
    simp [handlerRegs, hpe]
  obtain ⟨x1, he1, hargs, hm1, -, hr1, hrip1⟩ :=
    exec_setup ctx ρ mode _ rItems x hs4 hle hl
  have hs4' := hs4
  rw [setupItems_regs hle] at hs4'
  have hnotArg : ∀ i : Fin 16, (i = 0 ∨ i = 4 ∨ i = 5) → ∀ r ∈ X86.argRegs, r.idx ≠ i := by
    intro i hi r hr
    simp only [X86.argRegs, List.mem_cons, List.not_mem_nil, or_false] at hr
    rcases hi with rfl | rfl | rfl <;> rcases hr with rfl | rfl | rfl | rfl | rfl | rfl <;> decide
  have hx1rsp : x1.rsp = x.rsp := hr1 4 (hnotArg 4 (by simp))
  obtain ⟨y, hy, hyr, -, hyrip, hym⟩ := stImm_exec ctx (v.setWidth 32) x1
  have hyrsp : y.rsp = x.rsp := by
    show y.regs 4 = x.regs 4
    rw [hyr]; exact hx1rsp
  let next := y.rip + BitVec.ofNat 64 (Item.call (.handler n)).size
  let x2 := ((y.jump next).push next).jump (ctx.addrOf (.handler n))
  have hregs2 : ∀ i : Fin 16, i ≠ 4 → x2.regs i = y.regs i := by
    intro i hi
    simp [x2, State.jump, State.push, State.setMem, State.setReg, hi]
  have hrsp2' : x2.rsp = y.rsp - 8 := by
    simp [x2, State.rsp, State.reg, State.jump, State.push, State.setMem, State.setReg]
  have hrsp2 : x2.rsp = x.rsp - 8 := by rw [hrsp2', hyrsp]
  have hm2 : x2.mem = y.mem.write (y.rsp - 8) 8 next.toNat := rfl
  have hrbp2 : x2.reg .rbp = x.reg .rbp := by
    show x2.regs 5 = x.regs 5
    rw [hregs2 5 (by decide), hyr]; exact hr1 5 (hnotArg 5 (by simp))
  have hrax2 : x2.reg .rax = x.reg .rax := by
    show x2.regs 0 = x.regs 0
    rw [hregs2 0 (by decide), hyr]; exact hr1 0 (hnotArg 0 (by simp))
  -- The run.
  have hA1 : execItems ctx (rItems ++ [Item.stImm .d M.stackArg (v.setWidth 32)]) x = .ok y := by
    rw [X86.execItems_append, he1, ex_bind_ok', X86.execItems_cons, hy, ex_bind_ok'] <;> rfl
  have hexec : execItems ctx ((rItems ++ [Item.stImm .d M.stackArg (v.setWidth 32)]) ++
      [Item.call (.handler n)]) x = .ok x2 := by
    rw [X86.execItems_append, hA1, ex_bind_ok', X86.execItems_cons]; rfl
  -- The arguments.
  have hidx : ∀ i (h1 : i < ([a0, a1, a2, a3, .imm v] : List R.Arg).length)
      (h2 : i < ([a0, a1, a2, a3] : List R.Arg).length),
      ([a0, a1, a2, a3, .imm v] : List R.Arg)[i] = ([a0, a1, a2, a3] : List R.Arg)[i] := by
    intro i h1 h2
    rcases i with _ | _ | _ | _ | k
    · rfl
    · rfl
    · rfl
    · rfl
    · exfalso
      simp only [List.length_cons, List.length_nil] at h2
      omega
  have hA : ArgsIn ρ mode.pe x2 x2 [a0, a1, a2, a3, .imm v] := by
    refine ⟨fun i h1 h2 => ?_, fun _ _ => ⟨v, rfl, hv32, ?_⟩⟩
    · have hv : ∀ b, argVal ρ x2 b = argVal ρ x b := by
        intro b; cases b <;> simp [argVal, hrbp2, hrax2]
      have hl4 : (handlerRegs mode.pe).length = 4 := by rw [hpe]; rfl
      have h4' : i < ([a0, a1, a2, a3] : List R.Arg).length := by simp; omega
      rw [hv, hidx i h1 h4', hargs i h4' h2]
      have hne : ((handlerRegs mode.pe)[i]).idx ≠ 4 := by
        have hm := List.getElem_mem h2
        generalize (handlerRegs mode.pe)[i] = r at hm ⊢
        rw [hpe] at hm
        simp [handlerRegs] at hm
        rcases hm with rfl | rfl | rfl | rfl <;> decide
      show some (x1.regs _) = some (x2.regs _)
      rw [hregs2 _ hne, hyr]
    · have e40 : x2.rsp + 40 = x.rsp + 32 := by rw [hrsp2]; bv_omega
      rw [e40]
      show BitVec.ofNat 32 (x2.mem.readNat (x.rsp + 32) 4) = v.setWidth 32
      have hc : x2.mem.readNat (x.rsp + 32) 4 = y.mem.readNat (x.rsp + 32) 4 :=
        CallLemmas.readNat_congr fun i hi => by
          have h8 : 8 ≤ (x.rsp + 32 + BitVec.ofNat 64 i - (y.rsp - 8)).toNat := by
            rw [hyrsp]; exact above_push32 x.rsp i hi
          rw [hm2, Mem.write_other y.mem (y.rsp - 8) (x.rsp + 32 + BitVec.ofNat 64 i) 8 _ h8]
      rw [hc, hym, hx1rsp]
      exact memW_write_self _ _ _
  -- Memory.
  have hmem : ∀ a, ¬ InStack lo x.rsp a → ¬ InStackArg x.rsp a → x2.mem a = x.mem a := by
    intro a ha hb
    have h8 : 8 ≤ (a - (y.rsp - 8)).toNat := by
      rw [hyrsp]; exact CallLemmas.push_other lo x.rsp a hlo ha
    have h4 : 4 ≤ (a - (x1.rsp + 32)).toNat := by
      rw [hx1rsp]; unfold InStackArg at hb; omega
    rw [hm2, Mem.write_other y.mem (y.rsp - 8) a 8 _ h8, hym,
      Mem.write_other x1.mem (x1.rsp + 32) a 4 _ h4, hm1]
  -- The registers.
  have hpk : ∀ i : Fin 16, (∀ r ∈ handlerRegs mode.pe, r.idx ≠ i) → i ≠ 4 →
      x2.regs i = x.regs i := by
    intro i hi h4
    rw [hregs2 i h4, hyr]
    exact setup_regs ctx mode _ _ rItems x x1 hs4' he1 i hi
  -- The return address.
  have hret : x2.mem.read64 x2.rsp = next := by
    rw [hm2, hrsp2']
    exact CallLemmas.read64_write_self _ _ _
  refine ⟨x2, hexec, ⟨n, hn, by simp [x2, State.jump]⟩, hA, hrsp2, hrbp2, hpk, hmem, ?_⟩
  rw [hret]
  show y.rip + _ = _
  rw [hyrip, hrip1]
  simp [BitVec.add_assoc, BitVec.ofNat_add]

/-- `HRel` at the handler's entry: the change of `handler_call5` is confined to the stack below
`rsp` (`StackApart`) and the stack argument (`ArgApart`, e.g. `stackArg_apart`). -/
theorem hrel_after {lo : BitVec 64} {st : OpSem.State} {x x2 : X86.State}
    (hr : HRel st x) (hap : StackApart lo st x) (harg : ArgApart (InStackArg x.rsp) st x)
    (hrbp : x2.reg .rbp = x.reg .rbp)
    (hmem : ∀ a, ¬ InStack lo x.rsp a → ¬ InStackArg x.rsp a → x2.mem a = x.mem a) :
    HRel st x2 :=
  let h := (ArgApart.or (StackApart.argApart hap) harg).rel hr.rel hr.mem hrbp
    (fun a ha => hmem a (fun h1 => ha (.inl h1)) (fun h2 => ha (.inr h2)))
  ⟨h.1, h.2⟩

/-! ### Fetching the setup -/

/-- `FetchRun` of a list and one more item, run after it. -/
theorem fetchRun_append_single {ctx : Ctx} {S : BitVec 64 → Prop} {i : Item} :
    ∀ {l : List Item} {x : X86.State}, FetchRun ctx S l x →
      (∀ y, execItems ctx l x = .ok y → FetchRun ctx S [i] y) → FetchRun ctx S (l ++ [i]) x
  | [], x, _, h => h x rfl
  | j :: l, x, hl, h => by
    show FetchRun ctx S (j :: (l ++ [i])) x
    intro y hy
    obtain ⟨h1, h2, h3⟩ := hl y hy
    refine ⟨h1, h2, fetchRun_append_single h3 fun z hz => h z ?_⟩
    rw [X86.execItems_cons, hy]
    exact hz

/-- The stack argument's store keeps the bytes `S` (the code) when they are off the stack
argument. -/
theorem fetchRun_stImm {ctx : Ctx} {S : BitVec 64 → Prop} (w : BitVec 32) (y : X86.State)
    (hS : ∀ a, S a → ¬ InStackArg y.rsp a) : FetchRun ctx S [Item.stImm .d M.stackArg w] y := by
  intro z hz
  obtain ⟨z', hz', -, -, hrip, hm⟩ := stImm_exec ctx w y
  rw [hz'] at hz
  cases okInj hz
  refine ⟨hrip, fun a ha => ?_, trivial⟩
  have h4 : 4 ≤ (a - (y.rsp + 32)).toNat := by
    have := hS a ha
    unfold InStackArg at this
    omega
  rw [hm, Mem.write_other y.mem (y.rsp + 32) a 4 _ h4]

end Ryo.Proofs.HandlerStackArg
