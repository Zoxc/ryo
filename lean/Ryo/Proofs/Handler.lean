/-
Ryo.Proofs.Handler — the shape lemma for handler calls (aot.md §C2 "Shapes"): the canonical
sequence of `handler h args then` (`DecodeReduced.insn`: the argument setup, `call h`, the
shape's control flow) implements R's step of that instruction (`Ryo.Vm.R.Sem.stepView`:
`opSem` on `view`'s operands, then `Then.succ`), given the handler's contract.

- `argItem`, `setupItems`: the setup the decoder accepts (`handlerArgs`): argument `i` into
  `X86.argRegs[i]` by `fpItem` (`fp`), `mov r, rax` (the exception object), `setReg` (an
  immediate) or `lea r, [rip + ref]` (an address).
- `exec_setup`: the setup puts each argument's value (`argVal`: `rbp`, `rax`, the immediate,
  `ρ`'s address of the argument, `Linked`) in its register (`ArgsIn`), and changes only those
  registers, the flags and `rip`.
- `HandlerContract`: what a handler call does, as a trusted assumption on an abstract return
  relation `Ret h x x'` (`x` just after `call h`, at `h`'s linked entry, `AtHandler`; `x'`
  where it returns). It is `opSem` plus
  the footprint (reduced.md §C0.5, `vm/rt/tests/lean_opsem.rs` tests it): if `opSem h vals st`
  has no UB for any choice, the handler returns; and each return matches `opSem` for one of its
  choices with the relations (`HRel`: `Rel` and `MemRel`) kept, the control result in
  `rax`/`al` (`CtlIn`), `rsp` popped, the callee-saved registers kept, and x86 memory changed
  only at the frame's write ranges, in live allocations, in runtime-owned bytes and on the
  stack below `rsp`.
- `StackApart` (no initialized private frame byte and no live allocation byte on the stack
  below `rsp`, where the call pushes): `StackApart.rel` keeps `Rel` and `MemRel` across a
  change confined to that stack; `FrameSep.stackApart` derives it from the frame separation;
  `stackApart_all_false`: over every private byte, as first stated, it is unsatisfiable.
- `handler_op_sound`, `handler_br_sound`: from `HRel st x`, the setup, the call and the
  shape's tail (nothing for `op`; `test al, al; jz/jnz t` for `br`) reach the state
  after the instruction, related to `opSem`'s, with the branch taken exactly when `Then.succ`
  takes it.

The x86 side is item lists run in order (`execItems`, with the call's return through `Ret`),
not fetched from memory: the composition into `decode_sound` places them at their positions.
-/
import Ryo.Proofs.Inline.Mem
import Ryo.Proofs.ScopeMem
import Ryo.Proofs.Counter

set_option linter.constructorNameAsVariable false

namespace Ryo.Proofs.Handler

open Ryo.Spec Ryo.Vm Ryo.Vm.OpSem Ryo.X86 Ryo.Vm.Asm Ryo.Proofs.Inline
open Ryo.Proofs.Counter (CalleeSaved InStack)

/-! ### The argument setup -/

/-- The reference of an address argument (`addrArg`'s inverse). -/
def argRef : R.Arg → Option Ref
  | .const k => some (.const k)
  | .data d => some (.data d)
  | .sym s => some (.sym s)
  | .site s => some (.site s)
  | .ro o => some (.ro o)
  | _ => none

/-- The item that puts argument `a` in register `r` (`handlerArgs` accepts these). -/
def argItem (mode : Ryo.Obj.Mode) (r : Reg) : R.Arg → Option Item
  | .fp => some (fpItem r mode)
  | .exception => some (.mov r .rax)
  | .imm v => some (.setReg r v)
  | a => (argRef a).map (.lea r ·)

/-- A handler call's argument setup: argument `i` into `X86.argRegs[i]`, in order. -/
def setupItems (mode : Ryo.Obj.Mode) (args : List R.Arg) : Option (List Item) :=
  if args.length ≤ X86.argRegs.length then
    (args.zip X86.argRegs).mapM fun (a, r) => argItem mode r a
  else none

/-- The addresses `ρ` gives the address arguments are where they are linked. -/
def Linked (ctx : Ctx) (ρ : R.Addrs) : Prop :=
  ∀ a ref, argRef a = some ref → ∃ p, ρ a = some p ∧ ctx.addrOf ref = BitVec.ofNat 64 p.addr

/-- The value of argument `a` in state `x`. -/
def argVal (ρ : R.Addrs) (x : X86.State) : R.Arg → Option (BitVec 64)
  | .fp => some (x.reg .rbp)
  | .exception => some (x.reg .rax)
  | .imm v => some v
  | a => (ρ a).map fun p => BitVec.ofNat 64 p.addr

/-- The argument registers of `x` hold the values `args` have in `x0`. -/
def ArgsIn (ρ : R.Addrs) (x0 x : X86.State) (args : List R.Arg) : Prop :=
  ∀ i (h1 : i < args.length) (h2 : i < X86.argRegs.length), argVal ρ x0 args[i] = some (x.reg X86.argRegs[i])

/-! ### The contract -/

/-- The x86 state holds `opSem`'s: the frame and L0 memory. -/
structure HRel (st : OpSem.State) (x : X86.State) : Prop where
  rel : Rel st x
  mem : MemRel st x

/-- The control result of a handler in its return registers: `al` for a branch, `rax` for a
switch's index. -/
def CtlIn : Control → X86.State → Prop
  | .next, _ => True
  | .branch b, x => x.regW .b .rax = (if b then 1 else 0)
  | .index i, x => x.reg .rax = BitVec.ofNat 64 i

/-- `opSem` has no UB here: every choice succeeds or is outside the allowed set. -/
def NoUB (op : Full.Opcode) (vals : Operands) (st : OpSem.State) : Prop :=
  ∀ ch e, opSem op vals st ch = .error e → ∃ m, e = .noBehavior m

/-- The addresses a return may change: the frame's write ranges, live allocations (memory
through pointers), runtime-owned bytes and the stack below `rsp`. -/
def MayWrite (Owned : BitVec 64 → Prop) (lo : BitVec 64) (op : Full.Opcode) (vals : Operands)
    (st : OpSem.State) (x : X86.State) (a : BitVec 64) : Prop :=
  (∃ r ∈ wranges op vals, (a - fpAddr x r.1).toNat < r.2) ∨
  (∃ id al, st.mem.get? id = some al ∧ al.live = true ∧
    (a - BitVec.ofNat 64 al.addr).toNat < al.size) ∨
  Owned a ∨ InStack lo x.rsp a

/-- `x` is at the entry of `h`'s handler as linked in `ctx`. -/
def AtHandler (ctx : Ctx) (h : Full.Opcode) (x : X86.State) : Prop :=
  ∃ n, Full.Opcode.ofNat? n = some h ∧ x.rip = ctx.addrOf (.handler n)

/-- The handler contract (trusted; see the module comment). `x` is the state just after
`call h`: at the handler (`AtHandler`), the argument registers set, the return address at
`rsp`. -/
structure HandlerContract (ctx : Ctx) (ρ : R.Addrs) (fpArg : Bool) (Owned : BitVec 64 → Prop)
    (lo : BitVec 64) (Ret : Full.Opcode → X86.State → X86.State → Prop) : Prop where
  returns : ∀ h args vals st x, h.hasHandler = true → R.unpack ρ h fpArg args = some vals →
    AtHandler ctx h x → ArgsIn ρ x x args → HRel st x → NoUB h vals st →
    (∃ ch r, opSem h vals st ch = .ok r) → ∃ x', Ret h x x'
  sound : ∀ h args vals st x x', h.hasHandler = true → R.unpack ρ h fpArg args = some vals →
    AtHandler ctx h x → ArgsIn ρ x x args → HRel st x → NoUB h vals st → Ret h x x' →
    ∃ ch ctl st', opSem h vals st ch = .ok (ctl, st') ∧ HRel st' x' ∧ CtlIn ctl x' ∧
      x'.rsp = x.rsp + 8 ∧ x'.rip = x.mem.read64 x.rsp ∧
      (∀ i, CalleeSaved i → x'.regs i = x.regs i) ∧
      ∀ a, ¬ MayWrite Owned lo h vals st x a → x'.mem a = x.mem a

/-! ### The setup -/

private theorem argItem_exec (ctx : Ctx) (ρ : R.Addrs) (mode : Ryo.Obj.Mode) (r : Reg)
    (a : R.Arg) (it : Item) (x : X86.State) (h : argItem mode r a = some it)
    (hl : Linked ctx ρ) :
    ∃ y, it.exec ctx x = .ok y ∧ argVal ρ x a = some (y.reg r) ∧ y.mem = x.mem ∧
      y.xmm = x.xmm ∧ (∀ i, i ≠ r.idx → y.regs i = x.regs i) ∧
      y.rip = x.rip + BitVec.ofNat 64 it.size := by
  have hset : ∀ (v : BitVec 64) (f : Option X86.Flags),
      ∃ y : X86.State, y = Option.elim f ((x.jump (x.rip + BitVec.ofNat 64 it.size)).setReg r v)
        (((x.jump (x.rip + BitVec.ofNat 64 it.size)).setReg r v).setFlags ·) ∧
      y.reg r = v ∧ y.mem = x.mem ∧ y.xmm = x.xmm ∧ (∀ i, i ≠ r.idx → y.regs i = x.regs i) ∧
      y.rip = x.rip + BitVec.ofNat 64 it.size := by
    intro v f
    cases f <;> exact ⟨_, rfl, by simp [State.reg, State.setReg, State.setFlags],
      rfl, rfl, fun i hi => by simp [State.setReg, State.setFlags, State.jump, hi], rfl⟩
  have hlink := hl a
  cases a with
  | fp =>
    simp only [argItem, fpItem, Option.some.injEq] at h
    split at h <;> subst h
    · obtain ⟨y, hy, h1, h2⟩ := hset (x.reg .rbp) none
      exact ⟨y, by rw [hy]; rfl, by rw [h1]; rfl, h2⟩
    · obtain ⟨y, hy, h1, h2⟩ := hset (x.reg .rbp) none
      refine ⟨y, by rw [hy]; simp [Item.exec, State.ea, M.frame, State.jump, State.reg]; rfl, ?_, h2⟩
      simp [argVal, h1]
  | exception =>
    simp only [argItem, Option.some.injEq] at h; subst h
    obtain ⟨y, hy, h1, h2⟩ := hset (x.reg .rax) none
    exact ⟨y, by rw [hy]; rfl, by rw [h1]; rfl, h2⟩
  | imm v =>
    simp only [argItem, Option.some.injEq] at h; subst h
    by_cases h0 : setForm v == 0
    · have hv : v = 0 := by
        unfold setForm at h0
        split at h0
        · next hv => simpa using hv
        · split at h0
          · simp at h0
          · split at h0 <;> simp at h0
      obtain ⟨y, hy, h1, h2⟩ := hset 0 (some (logicFlags (0 : BitVec 32)))
      exact ⟨y, by rw [hy]; simp only [Item.exec, h0]; rfl, by rw [h1, hv]; rfl, h2⟩
    · obtain ⟨y, hy, h1, h2⟩ := hset v none
      exact ⟨y, by rw [hy]; simp only [Item.exec, h0]; rfl, by rw [h1]; rfl, h2⟩
  | const _ | data _ | sym _ | site _ | ro _ =>
    simp only [argItem, argRef, Option.map_some, Option.some.injEq] at h; subst h
    obtain ⟨p, hp, ha⟩ := hlink _ rfl
    obtain ⟨y, hy, h1, h2⟩ := hset (ctx.addrOf _) none
    exact ⟨y, by rw [hy]; rfl, by simp [argVal, hp, h1, ha], h2⟩

private theorem setup_exec (ctx : Ctx) (ρ : R.Addrs) (mode : Ryo.Obj.Mode) (hl : Linked ctx ρ) :
    ∀ (args : List R.Arg) (regs : List Reg) (items : List Item) (x : X86.State),
    regs.Pairwise (fun a b => a.idx ≠ b.idx) → (∀ r ∈ regs, r.idx ≠ Reg.rax.idx ∧ r.idx ≠ Reg.rbp.idx) →
    (args.zip regs).mapM (fun (a, r) => argItem mode r a) = some items →
    ∃ x1, execItems ctx items x = .ok x1 ∧
      (∀ i (h1 : i < args.length) (h2 : i < regs.length), argVal ρ x args[i] = some (x1.reg regs[i])) ∧
      x1.mem = x.mem ∧ x1.xmm = x.xmm ∧ (∀ i : Fin 16, (∀ r ∈ regs, r.idx ≠ i) → x1.regs i = x.regs i) ∧
      x1.reg .rax = x.reg .rax ∧ x1.reg .rbp = x.reg .rbp ∧
      x1.rip = x.rip + BitVec.ofNat 64 (items.map Item.size).sum := by
  intro args
  induction args with
  | nil =>
    intro regs items x _ _ h
    simp only [List.zip_nil_left, List.mapM_nil, pure, Option.some.injEq] at h
    subst h
    exact ⟨x, rfl, fun i h1 => absurd h1 (by simp), rfl, rfl, fun _ _ => rfl, rfl, rfl, by simp⟩
  | cons a args ih =>
    intro regs items x hp hn h
    cases regs with
    | nil =>
      simp only [List.zip_nil_right, List.mapM_nil, pure, Option.some.injEq] at h
      subst h
      exact ⟨x, rfl, fun i _ h2 => absurd h2 (by simp), rfl, rfl, fun _ _ => rfl, rfl, rfl, by simp⟩
    | cons r regs =>
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
          obtain ⟨y, hy, hv, hm, hx, hregs, hrip⟩ := argItem_exec ctx ρ mode r a it x hit hl
          have hp' := List.pairwise_cons.mp hp
          obtain ⟨x1, he, hargs, hm1, hx1, hregs1, hrax1, hrbp1, hrip1⟩ :=
            ih regs its y hp'.2 (fun r' hr' => hn r' (List.mem_cons_of_mem _ hr')) hrest
          have hrn := hn r (List.mem_cons_self ..)
          have hyrax : y.reg .rax = x.reg .rax := hregs _ (Ne.symm hrn.1)
          have hyrbp : y.reg .rbp = x.reg .rbp := hregs _ (Ne.symm hrn.2)
          have hval : ∀ b, argVal ρ y b = argVal ρ x b := by
            intro b; cases b <;> simp [argVal, hyrax, hyrbp]
          refine ⟨x1, by rw [execItems_cons, hy, ex_bind_ok']; exact he, ?_, hm1.trans hm,
            hx1.trans hx, ?_, hrax1.trans hyrax, hrbp1.trans hyrbp, ?_⟩
          · intro i h1 h2
            cases i with
            | zero =>
              simp only [List.getElem_cons_zero]
              rw [hv]
              show some (y.regs r.idx) = some (x1.regs r.idx)
              rw [hregs1 r.idx (fun r' hr' => Ne.symm (hp'.1 r' hr'))]
            | succ i =>
              simp only [List.getElem_cons_succ]
              rw [← hval]
              exact hargs i (by simpa using h1) (by simpa using h2)
          · intro i hi
            rw [hregs1 i (fun r' hr' => hi r' (List.mem_cons_of_mem _ hr')),
              hregs i (fun he => hi r (List.mem_cons_self ..) he.symm)]
          · rw [hrip1, hrip]
            simp [BitVec.add_assoc, BitVec.ofNat_add]


/-- The setup puts each argument's value in its register (see the module comment). -/
theorem exec_setup (ctx : Ctx) (ρ : R.Addrs) (mode : Ryo.Obj.Mode) (args : List R.Arg)
    (items : List Item) (x : X86.State) (hs : setupItems mode args = some items)
    (hl : Linked ctx ρ) :
    ∃ x1, execItems ctx items x = .ok x1 ∧ ArgsIn ρ x x1 args ∧ x1.mem = x.mem ∧
      x1.xmm = x.xmm ∧ (∀ i : Fin 16, (∀ r ∈ X86.argRegs, r.idx ≠ i) → x1.regs i = x.regs i) ∧
      x1.rip = x.rip + BitVec.ofNat 64 (items.map Item.size).sum := by
  unfold setupItems at hs
  split at hs
  · obtain ⟨x1, he, ha, hm, hx, hr, -, -, hrip⟩ := setup_exec ctx ρ mode hl args X86.argRegs items x
      (by decide) (by decide) hs
    exact ⟨x1, he, ha, hm, hx, hr, hrip⟩
  · cases hs

/-! ### The shapes `op` and `br` -/

private theorem foldr_congr' (f g : Nat → Nat) : ∀ (l : List Nat), (∀ i ∈ l, f i = g i) →
    l.foldr (fun i acc => f i + 256 * acc) 0 = l.foldr (fun i acc => g i + 256 * acc) 0
  | [], _ => rfl
  | a :: l, h => by
    simp only [List.foldr_cons]
    rw [h a (by simp), foldr_congr' f g l (fun i hi => h i (by simp [hi]))]

private theorem readNat_zero (m : Mem) (a : BitVec 64) : m.readNat a 0 = 0 := rfl

private theorem readNat_succ (m : Mem) (a : BitVec 64) (k : Nat) :
    m.readNat a (k + 1) = (m a).toNat + 256 * m.readNat (a + 1) k := by
  unfold Mem.readNat
  rw [List.range_succ_eq_map]
  simp only [List.foldr_cons, List.foldr_map]
  congr 2
  · simp
  · apply foldr_congr'
    intro i _
    have : a + BitVec.ofNat 64 (i + 1) = a + 1 + BitVec.ofNat 64 i := by
      apply BitVec.eq_of_toNat_eq; simp; omega
    simp only [this]

private theorem mod_split (x n : Nat) :
    x % 2 ^ (8 * (n + 1)) = x % 256 + 256 * (x / 256 % 2 ^ (8 * n)) := by
  rw [show 8 * (n + 1) = 8 + 8 * n by omega, Nat.pow_add]
  exact Nat.mod_mul

private theorem readNat_write_self (m : Mem) (a : BitVec 64) (n v : Nat) (hn : n < 2 ^ 64) :
    ∀ (j k : Nat), j + k ≤ n →
    (m.write a n v).readNat (a + BitVec.ofNat 64 j) k = (v >>> (8 * j)) % 2 ^ (8 * k)
  | _, 0, _ => by simp [readNat_zero]; omega
  | j, k + 1, h => by
    rw [readNat_succ]
    have e : a + BitVec.ofNat 64 j + 1 = a + BitVec.ofNat 64 (j + 1) := by
      apply BitVec.eq_of_toNat_eq; simp; omega
    rw [e, readNat_write_self m a n v hn (j + 1) k (by omega), mod_split]
    have hb : m.write a n v (a + BitVec.ofNat 64 j) = UInt8.ofNat (v >>> (8 * j)) := by
      simp only [Mem.write]
      have : (a + BitVec.ofNat 64 j - a).toNat = j := by
        rw [BitVec.add_comm, BitVec.add_sub_cancel]; simp; omega
      rw [this, ite_eq_left (by omega)]
    rw [hb, UInt8.toNat_ofNat']
    congr 2
    rw [Nat.shiftRight_eq_div_pow, Nat.shiftRight_eq_div_pow, Nat.div_div_eq_div_mul,
      show 8 * (j + 1) = 8 * j + 8 by omega, Nat.pow_add]

private theorem read64_write_self (m : Mem) (a v : BitVec 64) :
    (m.write a 8 v.toNat).read64 a = v := by
  have := readNat_write_self m a 8 v.toNat (by decide) 0 8 (by omega)
  simp only [BitVec.add_zero, Nat.mul_zero, Nat.shiftRight_zero] at this
  simp only [Mem.read64, this]
  apply BitVec.eq_of_toNat_eq
  simp [Nat.mod_eq_of_lt v.isLt]

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

/-- No live allocation's byte is on the stack below `rsp` (`[lo, rsp)`, where calls push and
callees write). -/
def AllocsApart (lo : BitVec 64) (st : OpSem.State) (x : X86.State) : Prop :=
  ∀ id al, st.mem.get? id = some al → al.live = true → ∀ i < al.size,
    ¬ InStack lo x.rsp (BitVec.ofNat 64 (al.addr + i))

/-- No byte the relations read is on the stack below `rsp` (where the call pushes): no
initialized private frame byte (an `Uninit` one relates to any x86 byte), no live allocation's
byte (`AllocsApart`; escaped frame bytes are allocation bytes). Over every private byte, as it
was first stated, it was false whenever `[lo, rsp)` is non-empty (`stackApart_all_false`). -/
def StackApart (lo : BitVec 64) (st : OpSem.State) (x : X86.State) : Prop :=
  (∀ o : Int, -2 ^ 63 ≤ o → o < 2 ^ 63 → st.escapedAt o = none → st.frame o ≠ .uninit →
    ¬ InStack lo x.rsp (fpAddr x o)) ∧
  AllocsApart lo st x

/-- `StackApart` as it was first stated: over every frame byte `byteAt` reads. -/
def StackApartAll (lo : BitVec 64) (st : OpSem.State) (x : X86.State) : Prop :=
  ∀ o : Int, -2 ^ 63 ≤ o → o < 2 ^ 63 → (∃ b, st.byteAt o = .ok b) →
    ¬ InStack lo x.rsp (fpAddr x o)

/-- The old statement is unsatisfiable as soon as the stack area below `rsp` is non-empty and
the byte at `rsp - 1` is private (e.g. no frame object has escaped): every address is `fp + o`
for some `o`, and a private `o` always has a byte. -/
theorem stackApart_all_false {lo : BitVec 64} {st : OpSem.State} {x : X86.State}
    (hlo : lo.toNat < x.rsp.toNat)
    (hp : st.escapedAt ((x.rsp - 1 - x.reg .rbp).toInt) = none) : ¬ StackApartAll lo st x := by
  intro h
  generalize ho : (x.rsp - 1 - x.reg .rbp).toInt = o at hp
  have hb : st.byteAt o = .ok (st.frame o) := by
    unfold OpSem.State.byteAt; rw [hp]; rfl
  have hr := BitVec.le_toInt (x := x.rsp - 1 - x.reg .rbp)
  have hr' := BitVec.toInt_lt (x := x.rsp - 1 - x.reg .rbp)
  apply h o (by rw [← ho]; simpa using hr) (by rw [← ho]; simpa using hr') ⟨_, hb⟩
  have ha : fpAddr x o = x.rsp - 1 := by
    rw [fpAddr, ← ho, BitVec.ofInt_toInt]; bv_omega
  rw [ha]
  simp only [InStack]
  have : (x.rsp - 1).toNat = x.rsp.toNat - 1 := by
    rw [BitVec.toNat_sub]; simp; omega
  omega

/-- `StackApart` keeps the frame and memory relations across a change of x86 memory that is
confined to the stack below `rsp`, with `rbp` kept. -/
theorem StackApart.rel {lo : BitVec 64} {st : OpSem.State} {x y : X86.State}
    (hap : StackApart lo st x) (hr : Rel st x) (hm : MemRel st x)
    (hb : y.reg .rbp = x.reg .rbp) (hmem : ∀ a, ¬ InStack lo x.rsp a → y.mem a = x.mem a) :
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

/-- `StackApart` from the frame separation: the initialized private bytes lie in the frame
window (`FrameSep`), whose addresses are off the stack below `rsp` (`hwin`; `stack_off_window`
in the body), and the allocations are off it too (`AllocsApart`, an environment fact: the
stack below `rsp` is no allocation's). -/
theorem FrameSep.stackApart {lo : BitVec 64} {wlo whi : Int} {st : OpSem.State} {x : X86.State}
    (hs : ScopeMem.FrameSep wlo whi st x)
    (hwin : ∀ o, wlo ≤ o → o < whi → ¬ InStack lo x.rsp (fpAddr x o))
    (hal : AllocsApart lo st x) : StackApart lo st x :=
  ⟨fun o _ _ he hu => let ⟨h1, h2⟩ := hs.init o he hu; hwin o h1 h2, hal⟩

/-- The frame window `[wlo, whi)` is above `rsp` when `rsp ≤ fp + wlo` (in the body
`rsp = fp - F`, `wlo = -F`) and its addresses don't wrap. -/
theorem stack_off_window {lo : BitVec 64} {x : X86.State} {wlo whi : Int}
    (hsp : (x.rsp.toNat : Int) ≤ (x.reg .rbp).toNat + wlo)
    (htop : ((x.reg .rbp).toNat : Int) + whi ≤ 2 ^ 64) :
    ∀ o, wlo ≤ o → o < whi → ¬ InStack lo x.rsp (fpAddr x o) := by
  intro o h1 h2
  simp only [InStack, fpAddr, BitVec.toNat_add, BitVec.toNat_ofInt]
  have := (x.reg .rbp).isLt
  have := x.rsp.isLt
  omega

/-- A handler call of shape `op`: the setup and `call h` reach the handler (`x1`), which
returns if `opSem` can step; each return is at the next item, related to `opSem`'s result for
one of its choices, with `rsp` and the callee-saved registers of `x`. -/
theorem handler_op_sound {ρ : R.Addrs} {mode : Ryo.Obj.Mode} {Owned : BitVec 64 → Prop}
    {lo : BitVec 64} {Ret : Full.Opcode → X86.State → X86.State → Prop}
    (ctx : Ctx) (hC : HandlerContract ctx ρ mode.fpArg Owned lo Ret) (hl : Linked ctx ρ)
    {h : Full.Opcode} {n : Nat} (hn : Full.Opcode.ofNat? n = some h) (hh : h.hasHandler = true)
    {args : List R.Arg} {vals : Operands} {items : List Item}
    (hu : R.unpack ρ h mode.fpArg args = some vals) (hs : setupItems mode args = some items)
    {st : OpSem.State} {x : X86.State} (hr : HRel st x) (hno : NoUB h vals st)
    (hap : StackApart lo st x) (hlo : lo.toNat + 8 ≤ x.rsp.toNat) :
    ∃ x1, execItems ctx (items ++ [Item.call (.handler n)]) x = .ok x1 ∧
      ((∃ ch r, opSem h vals st ch = .ok r) → ∃ x', Ret h x1 x') ∧
      ∀ x', Ret h x1 x' → ∃ ch ctl st', opSem h vals st ch = .ok (ctl, st') ∧ HRel st' x' ∧
        CtlIn ctl x' ∧ x'.rsp = x.rsp ∧
        x'.rip = x.rip + BitVec.ofNat 64 ((items ++ [Item.call (.handler n)]).map Item.size).sum ∧
        (∀ i, CalleeSaved i → x'.regs i = x.regs i) := by
  obtain ⟨x1, he1, hargs, hm1, hx1, hr1, hrip1⟩ := exec_setup ctx ρ mode args items x hs hl
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
    intro i hi; simp [x2, State.jump, State.push, State.setMem, State.setReg, hi]
  have hmem2 : ∀ a, ¬ InStack lo x.rsp a → x2.mem a = x.mem a := by
    intro a ha
    simp only [x2, State.jump, State.push, State.setMem, State.setReg]
    rw [Mem.write_other _ _ _ _ _ (by
      show 8 ≤ (a - (x1.rsp - 8)).toNat
      rw [hx1sp]; exact push_other lo x.rsp a hlo ha), hm1]
  have hret : x2.mem.read64 x2.rsp = next := by
    simp only [x2, State.jump, State.push, State.setMem, State.setReg, State.rsp, State.reg]
    simp only [↓reduceIte]
    exact read64_write_self _ _ _
  have hrbp : x2.reg .rbp = x.reg .rbp := by
    show x2.regs 5 = x.regs 5
    rw [hregs2 5 (by decide), hkeep 5 (by simp [CalleeSaved])]
  have hrax : x2.reg .rax = x.reg .rax := by
    show x2.regs 0 = x.regs 0
    rw [hregs2 0 (by decide), hkeep 0 (by simp)]
  have hfp : ∀ o, fpAddr x2 o = fpAddr x o := fun o => by simp [fpAddr, hrbp]
  have hexec : execItems ctx (items ++ [Item.call (.handler n)]) x = .ok x2 := by
    have happ : execItems ctx (items ++ [Item.call (.handler n)]) x =
        (execItems ctx items x >>= execItems ctx [Item.call (.handler n)]) := by
      simp only [execItems, List.foldlM_append]; rfl
    rw [happ, he1, ex_bind_ok', execItems_cons]; rfl
  have hA : ArgsIn ρ x2 x2 args := by
    intro i h1 h2
    have hv : ∀ b, argVal ρ x2 b = argVal ρ x b := by
      intro b; cases b <;> simp [argVal, hrbp, hrax]
    rw [hv, hargs i h1 h2]
    suffices hs : x2.regs (X86.argRegs[i]).idx = x1.regs (X86.argRegs[i]).idx by
      show some (x1.regs _) = some (x2.regs _); rw [hs]
    apply hregs2
    have hm : X86.argRegs[i] ∈ X86.argRegs := List.getElem_mem h2
    generalize X86.argRegs[i] = r at hm ⊢
    simp only [X86.argRegs, List.mem_cons, List.not_mem_nil, or_false] at hm
    rcases hm with rfl | rfl | rfl | rfl | rfl | rfl <;> decide
  have hat : AtHandler ctx h x2 := ⟨n, hn, by simp [x2, State.jump]⟩
  have hH : HRel st x2 :=
    let ⟨h1, h2⟩ := hap.rel hr.rel hr.mem hrbp hmem2; ⟨h1, h2⟩
  refine ⟨x2, hexec, fun hex => hC.returns h args vals st x2 hh hu hat hA hH hno hex, ?_⟩
  intro x' hR
  obtain ⟨ch, ctl, st', hop, hH', hctl, hsp', hrip', hsaved, -⟩ :=
    hC.sound h args vals st x2 x' hh hu hat hA hH hno hR
  refine ⟨ch, ctl, st', hop, hH', hctl, ?_, ?_, ?_⟩
  · rw [hsp', hrsp2]; exact BitVec.sub_add_cancel _ _
  · rw [hrip', hret]
    simp [next, hrip1, BitVec.add_assoc, BitVec.ofNat_add]
  · intro i hi
    rw [hsaved i hi, hregs2 i (by rcases hi with rfl | rfl | rfl | rfl | rfl | rfl <;> decide),
      hkeep i (Or.inr (Or.inr hi))]

/-- The tail of a `br` handler call: `test al, al` and `jz t` (taken when the handler returned
`false`: `neg`) or `jnz t`. Taken exactly when `Then.succ` takes the branch. -/
theorem br_tail (ctx : Ctx) (b neg : Bool) (t : BitVec 32) (long : Bool) (x : X86.State)
    (hal : x.regW .b .rax = (if b then 1 else 0)) :
    ∃ x', execItems ctx [.testAl, .branch (if neg then .z else .nz) t long] x = .ok x' ∧
      x'.regs = x.regs ∧ x'.mem = x.mem ∧ x'.xmm = x.xmm ∧
      x'.rip = (if b != neg then ctx.base + t.setWidth 64
        else x.rip + BitVec.ofNat 64 ((Item.testAl).size + (Item.branch (if neg then .z else .nz) t long).size)) := by
  have hal' : (x.regs 0).setWidth W.b.bits = (if b then 1 else 0) := hal
  cases b <;> cases neg <;> simp only [Bool.false_eq_true, ite_true, ite_false, W.bits] at hal' <;>
    simp [Functor.map, Except.map, execItems_cons, execItems_nil, Item.exec, State.regW, State.reg, hal', logicFlags, Cond.eval, need,
      State.setFlags, State.jump, bind, Except.bind, pure, Except.pure, BitVec.add_assoc, W.bits, BitVec.ofNat_add]

end Ryo.Proofs.Handler
